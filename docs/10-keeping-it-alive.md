# <img src="assets/icons/license.png" class="nk-title-icon" alt=""> Chapter 10 — Keeping it alive

Until now the realm only runs while a terminal holds it open. This chapter hands that job
to the Pi itself: the servers become **systemd services** that start on boot and restart on
failure, a **nightly backup** protects the databases (with a *proven* restore), and MySQL
**moves onto the NVMe**, off the microSD that a database would otherwise wear out.

> Everything here runs **on the Pi** (`tpgaming01 $`). SSH in first:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```

## What this is

Three independent pieces of durability, done in order:

1. **systemd services** for `authserver` and `worldserver` — auto-start, auto-restart, log
   to the journal.
2. **Backups** — a nightly `mysqldump` of all four databases, timestamped and pruned, plus
   a restore test to prove they work.
3. **Move MySQL to the NVMe** — the datadir move deferred back in Chapter 03.

## Why it matters

A realm you have to hand-start after every reboot isn't really "up." And a database on a
microSD card, doing constant small writes, is a card-failure waiting to happen — which is
exactly why we also move it to the NVMe and back it up.

## Before you start

- Chapters 00–09 complete; the realm boots and you can log in.
- The install root is `/mnt/nvme/azerothcore-wotlk/env/dist`, MySQL 8.0 is running, and the
  four databases exist.

Reusable copies of every file below live in [`systemd/`](https://github.com/jetomev/pi-kognog-azerothcore/tree/main/systemd) and
[`scripts/`](https://github.com/jetomev/pi-kognog-azerothcore/tree/main/scripts).

---

## Part A — systemd services

### 1. Create the two unit files

They run as your **`tphome`** user (never root), from the install dir, and depend on MySQL
so they wait for the database at boot.

```
sudo tee /etc/systemd/system/azerothcore-authserver.service > /dev/null <<'EOF'
[Unit]
Description=AzerothCore authserver (Playerbots)
After=network-online.target mysql.service
Wants=network-online.target
Requires=mysql.service

[Service]
Type=simple
User=tphome
Group=tphome
WorkingDirectory=/mnt/nvme/azerothcore-wotlk/env/dist/bin
ExecStart=/mnt/nvme/azerothcore-wotlk/env/dist/bin/authserver
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF
```

```
sudo tee /etc/systemd/system/azerothcore-worldserver.service > /dev/null <<'EOF'
[Unit]
Description=AzerothCore worldserver (Playerbots)
After=network-online.target mysql.service
Wants=network-online.target
Requires=mysql.service

[Service]
Type=simple
User=tphome
Group=tphome
WorkingDirectory=/mnt/nvme/azerothcore-wotlk/env/dist/bin
ExecStart=/mnt/nvme/azerothcore-wotlk/env/dist/bin/worldserver
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
```

- **`Requires=` + `After=mysql.service`** — MySQL starts first at boot; the servers never
  meet a database that isn't ready.
- **`Restart=on-failure`** — a crash relaunches; a clean `.server shutdown` (exit 0) is
  respected and won't loop.

> Make sure no manually-started `authserver`/`worldserver` is running first
> (`pgrep -a worldserver`), or systemd can't bind ports `3724`/`8085`.

### 2. Enable, start, verify

```
sudo systemctl daemon-reload
sudo systemctl enable --now azerothcore-authserver.service
sudo systemctl enable --now azerothcore-worldserver.service
```

`worldserver` needs ~1–2 minutes to load maps before it opens `8085`. After that:

```
systemctl is-active azerothcore-authserver azerothcore-worldserver   # active, active
ss -tlnp | grep -E ':3724|:8085'                                     # both LISTEN
```

### 3. Silence the console (`AC>`) spam

Under systemd, `worldserver`'s interactive console has no keyboard to read from, so it
loops reprinting `AC>` forever and floods the journal. Disable it — you administer the realm
**in-game as GM** instead:

```
sed -i -E 's/^Console\.Enable\s*=.*/Console.Enable = 0/' /mnt/nvme/azerothcore-wotlk/env/dist/etc/worldserver.conf
sudo systemctl restart azerothcore-worldserver
```

Confirm the journal is now real log lines, not `AC>`:

```
sudo journalctl -u azerothcore-worldserver -n 15 --no-pager
```

If you ever want the real console back, stop the service and run `./worldserver` by hand.

### 4. The reboot test

The whole point — prove it comes back on its own:

```
sudo systemctl reboot
```

Wait ~2–3 minutes, SSH back in, and confirm **without touching anything**:

```
uptime                                                               # a few minutes
systemctl is-active azerothcore-authserver azerothcore-worldserver   # active, active
ss -tlnp | grep -E ':3724|:8085'                                     # both LISTEN
```

### 5. (Optional) silence the priority-class warning

`worldserver` logs `Can't set process priority class` because a normal user can't raise
scheduling priority. Grant just that one capability with a drop-in:

```
sudo mkdir -p /etc/systemd/system/azerothcore-worldserver.service.d
sudo tee /etc/systemd/system/azerothcore-worldserver.service.d/nice.conf > /dev/null <<'EOF'
[Service]
AmbientCapabilities=CAP_SYS_NICE
EOF
sudo systemctl daemon-reload
sudo systemctl restart azerothcore-worldserver
```

After the restart the log shows `Process priority class set to -15` instead of the denial.

---

## Part B — backups

### 6. The backup script

Dumps all four databases to the **NVMe** (7-day retention), then places a second copy of
the three **irreplaceable** databases on the **microSD** (3-day retention) — so a single
dead disk can never take the data *and* its backups together. It runs as root and
authenticates through MySQL's **local socket** (`auth_socket`) — so no password is ever
stored.

```
sudo tee /usr/local/bin/acore-backup.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Primary backups (NVMe) - all four databases
BACKUP_DIR="/mnt/nvme/backups/mysql"
RETENTION_DAYS=7
DBS=(acore_auth acore_characters acore_world acore_playerbots)

# Second copy (microSD, root filesystem) - only the irreplaceable databases.
# acore_world is static, regenerable game data, so it stays off the card.
SD_BACKUP_DIR="/var/backups/acore-mysql"
SD_RETENTION_DAYS=3
DYNAMIC_DBS=(acore_auth acore_characters acore_playerbots)

mkdir -p "$BACKUP_DIR" "$SD_BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"

for db in "${DBS[@]}"; do
    mysqldump --single-transaction --quick --routines --triggers "$db" \
        | gzip > "$BACKUP_DIR/${db}-${STAMP}.sql.gz"
done

for db in "${DYNAMIC_DBS[@]}"; do
    cp "$BACKUP_DIR/${db}-${STAMP}.sql.gz" "$SD_BACKUP_DIR/"
done

find "$BACKUP_DIR" -name '*.sql.gz' -type f -mtime +"$RETENTION_DAYS" -delete
find "$SD_BACKUP_DIR" -name '*.sql.gz' -type f -mtime +"$SD_RETENTION_DAYS" -delete
EOF
sudo chmod +x /usr/local/bin/acore-backup.sh
```

- **`--single-transaction`** takes a consistent snapshot *without locking* — safe to run
  while people play.
- **`--quick`** streams rows, easy on the Pi's RAM.
- **Why only three DBs on the microSD:** `acore_world` is 76 MB of every 95 MB set, and
  it's static, regenerable game data. Leaving it off the card cuts the nightly microSD
  write to ~20 MB (kind to the card's endurance) while keeping every byte you can't
  recreate: accounts, characters, bot state.
- **Why 7 days, not 3:** retention should outlive your *time to notice* a problem. If
  corruption sneaks in on a Tuesday and you only play weekends, a 3-day window has already
  recycled every clean copy.

Prove it by hand:

```
sudo /usr/local/bin/acore-backup.sh
ls -lh /mnt/nvme/backups/mysql/       # four .sql.gz files; acore_world is the big one
ls -lh /var/backups/acore-mysql/      # exactly three files, ~20 MB total
```

> Want copies **off the Pi entirely** (a USB stick, or pulled to your desktop)? That's the
> optional chapter: **[Off-box backups](optional-offbox-backups.md)** — do it before any
> wipe or reinstall.

### 7. Run it nightly

```
sudo tee /etc/systemd/system/acore-backup.service > /dev/null <<'EOF'
[Unit]
Description=AzerothCore MySQL backup (all four databases)
After=mysql.service
Requires=mysql.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/acore-backup.sh
EOF
```

```
sudo tee /etc/systemd/system/acore-backup.timer > /dev/null <<'EOF'
[Unit]
Description=Nightly AzerothCore MySQL backup

[Timer]
OnCalendar=*-*-* 04:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

```
sudo systemctl daemon-reload
sudo systemctl enable --now acore-backup.timer
systemctl list-timers acore-backup.timer --no-pager   # NEXT shows the coming 04:00
```

**`Persistent=true`** means a night the Pi is off runs the backup at next boot rather than
skipping it.

### 8. Restore test — the step nobody should skip

A backup you've never restored is a hope, not a backup. Prove one loads — *safely*, into a
throwaway database, so the live realm is never touched. (Each dump is a single database with
no `CREATE DATABASE`/`USE` baked in, so it loads into any database you choose.)

```
LATEST=$(ls -t /mnt/nvme/backups/mysql/acore_characters-*.sql.gz | head -1)
sudo mysql -e "DROP DATABASE IF EXISTS restore_test; CREATE DATABASE restore_test;"
zcat "$LATEST" | sudo mysql restore_test
sudo mysql -N -e "SELECT COUNT(*) FROM restore_test.characters;"     # restored
sudo mysql -N -e "SELECT COUNT(*) FROM acore_characters.characters;" # live — must match
sudo mysql -e "DROP DATABASE restore_test;"
```

**The two counts matching = proof.** Then the temp database is dropped so nothing lingers.

---

## Part C — move MySQL to the NVMe

The riskiest step, made safe by two nets: the verified backups above, and keeping the old
datadir intact until the new one is confirmed. The one Ubuntu trap is **AppArmor**, which
confines `mysqld` to `/var/lib/mysql` and will refuse the new path until told otherwise.

### 9. Quiesce and copy

```
sudo systemctl stop azerothcore-worldserver azerothcore-authserver
sudo systemctl stop mysql
sudo systemctl is-active mysql                 # inactive

sudo rsync -aHAX --info=progress2 /var/lib/mysql/ /mnt/nvme/mysql/
sudo du -sh /var/lib/mysql /mnt/nvme/mysql     # sizes match
sudo ls -ld /mnt/nvme/mysql                    # owned mysql:mysql
```

`rsync -aHAX` preserves ownership, permissions, hardlinks, ACLs, and xattrs — MySQL is picky
about all of them. The original is untouched (your rollback).

### 10. Point MySQL + AppArmor at the new path

Set the datadir with a drop-in read **last** (so it wins, no editing the main config):

```
sudo tee /etc/mysql/mysql.conf.d/zz-datadir.cnf > /dev/null <<'EOF'
[mysqld]
datadir = /mnt/nvme/mysql
EOF
```

Then teach AppArmor. The vendor profile includes `local/usr.sbin.mysqld`, so append the new
rules there (mirroring the existing `/var/lib/mysql` lines) and reload:

```
sudo tee -a /etc/apparmor.d/local/usr.sbin.mysqld > /dev/null <<'EOF'
/mnt/nvme/mysql/ r,
/mnt/nvme/mysql/** rwk,
EOF
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
```

> **Do not start MySQL before the AppArmor reload** — it would be denied the new path and
> fail. If it does fail to start, `sudo journalctl -u mysql -n 20 --no-pager` and
> `sudo dmesg | grep -i apparmor` will show a `DENIED` line for `/mnt/nvme/mysql`.

### 11. Start, verify, and prove it by playing

```
sudo systemctl start mysql
sudo systemctl is-active mysql                 # active
sudo mysql -e "SELECT @@datadir;"              # /mnt/nvme/mysql/
sudo systemctl start azerothcore-authserver azerothcore-worldserver
```

Give worldserver its minute, then **log in from your client** and confirm your character is
there — reading from the new disk. Create a character, make bots, play, log off, and check
it all persisted. That in-game confirmation is the real proof.

### 12. Reclaim the microSD

Once you're in-world from the NVMe, rename the old datadir (kept as an instant rollback):

```
sudo mv /var/lib/mysql /var/lib/mysql.bak
systemctl is-active mysql                       # still active — MySQL never noticed
```

After a few days of confidence, delete it to free the space:

```
sudo rm -rf /var/lib/mysql.bak
```

## ✅ Checkpoint

Chapter 10 is done when:

- both servers are systemd services (`is-active` → `active`), and the realm **survives a
  reboot with no manual start**,
- the nightly backup timer is scheduled and a **restore test's row counts matched**,
- `SELECT @@datadir` reports `/mnt/nvme/mysql/`, and you've **logged in and played** from
  the NVMe-hosted database.

The realm is now self-starting, self-healing, backed up, and running entirely off the NVMe —
the microSD holds only the OS.

## ⚠ If it went wrong

- **Journal floods with `AC>`** — the console is enabled under systemd; set
  `Console.Enable = 0` (Step 3).
- **MySQL won't start after the move** — almost always AppArmor. Confirm the two
  `/mnt/nvme/mysql` rules are in `/etc/apparmor.d/local/usr.sbin.mysqld` and that you ran
  `apparmor_parser -r`. Check `dmesg | grep -i apparmor` for a `DENIED` path. Rollback is
  trivial: revert `zz-datadir.cnf` (or point it back at `/var/lib/mysql`) and restart.
- **Services won't bind the ports** — a hand-started server is still holding them; find it
  with `pgrep -a worldserver` / `pgrep -a authserver` and stop it.
