# <img src="assets/icons/brand.png" class="nk-title-icon" alt=""> Optional — Off-box backups

Chapter 10 left the realm backed up nightly on **two disks inside the Pi** (NVMe + microSD).
That covers the most likely failure — one disk dying. It does **not** cover the box itself:
a power surge, theft, a bad `rm -rf`, or the guide's own validation loop, which deliberately
wipes the machine. For those you need a copy that **lives somewhere else**.

This chapter gives two manual methods. Pick one, or use both. Neither needs anything to stay
plugged in or connected — they are deliberate, human-run safety copies.

> **The one rule: make an off-box copy BEFORE any wipe, reinstall, or risky experiment.**
> That moment — right before you break things on purpose — is exactly what these exist for.

## What you already have (from Chapter 10)

| Copy | Where | What | Retention |
|---|---|---|---|
| Primary | NVMe `/mnt/nvme/backups/mysql/` | all four databases | 7 days |
| Second | microSD `/var/backups/acore-mysql/` | the three irreplaceable DBs | 3 days |

Both are **on the Pi**. The methods below add copies that aren't.

## What actually needs saving

Your identity lives in three databases; the fourth is replaceable:

- `acore_auth` — your account and login. **Irreplaceable.**
- `acore_characters` — your characters and everything they own. **Irreplaceable.**
- `acore_playerbots` — the bot roster and state. **Irreplaceable.**
- `acore_world` — the static game world. Regenerable from the AzerothCore install, but the
  off-box methods copy it anyway (~76 MB) so a copy is always a *complete* restore set.

---

## Method 1 — pull to another Linux machine

A script on your **desktop** (not the Pi) pulls every dump over SSH with `rsync`. After
setup, an off-box backup is one command and your key passphrase.

### Before you start

- You can SSH from this machine to the Pi (Chapter 00's key:
  `ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220`).
- `rsync` is installed on **both** ends (the Pi has it since Chapter 06).

### 1. Install the script

Copy [`scripts/pull-backups.sh`](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/scripts/pull-backups.sh) somewhere on your desktop. A
tidy convention: keep realm tooling **next to the game client**, and let the backup *data*
land outside it (never store your archive inside a folder you might one day delete or
replace with a fresh client):

```
cp scripts/pull-backups.sh ~/Games/ChromieCraft_3.3.5a/pull-backups.sh
chmod +x ~/Games/ChromieCraft_3.3.5a/pull-backups.sh
```

Edit the variables at the top to match your machine (Pi address, key path, and where copies
should land — default `~/Backups/tpgaming01-mysql`).

### 2. Run it

On the desktop:

```
~/Games/ChromieCraft_3.3.5a/pull-backups.sh
```

Enter your key passphrase. Expected: an rsync transfer list of the `.sql.gz` files, then
`Off-box copy complete` with the newest files listed. (~200 MB for two full sets; seconds
on a LAN.)

Two deliberate design choices:
- **No `--delete`** — copies the Pi prunes after 7 days are **kept** on the desktop. The
  desktop is the long archive; the Pi stays lean.
- It pulls the **NVMe folder**, so every off-box copy contains all four databases.

Re-runs only transfer new files. Done.

---

## Method 2 — a USB drive

Plug a stick into the **Pi**, run one script, unplug when told. The copy then lives in a
drawer, a keychain, another building — wherever you put it.

### Before you start

- Any USB stick of **1 GB+** (8 GB+ recommended — a full set is ~200 MB and they
  accumulate), formatted `vfat`/`exFAT`/`ext4`. `vfat`/`exFAT` means any desktop can read
  it too. Existing files on the stick are untouched; the script only adds a folder.

### 1. Plug it in and identify it

```
lsblk -o NAME,SIZE,FSTYPE,LABEL,VENDOR,MODEL,MOUNTPOINTS
```

The stick appears as **`sda`** with a partition **`sda1`** — alongside the familiar
`mmcblk0` (microSD) and `nvme0n1`. Confirm the size and vendor match the stick you plugged
in. *Never guess at device names; this listing is the safety step.*

### 2. Install the script

Copy [`scripts/acore-usb-backup.sh`](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/scripts/acore-usb-backup.sh) onto the Pi as
`/usr/local/bin/acore-usb-backup.sh` and `sudo chmod +x` it (or paste it with `sudo tee`
as in Chapter 10).

Its guard rails, because writing to the wrong device is the classic self-inflicted wound:
- it **refuses** `mmcblk0*` and `nvme*` outright, no matter what you pass it;
- it checks the device exists and isn't already mounted;
- it **`sync`s and unmounts before saying "SAFE TO UNPLUG"** — so that message means
  exactly what it says. A `trap` unmounts even if the copy fails midway.

### 3. Run it

On the Pi:

```
sudo acore-usb-backup.sh              # default /dev/sda1
sudo acore-usb-backup.sh /dev/sdb1    # or name the partition explicitly
```

Expected: the rsync file list, then `Done. Drive unmounted - SAFE TO UNPLUG.` Unplug it.

### 4. Verify once (worth doing the first time)

Plug it back in and confirm the files really landed:

```
sudo mount /dev/sda1 /mnt/usb-backup && ls -lh /mnt/usb-backup/tpgaming01-mysql/ && sudo umount /mnt/usb-backup
```

Every dump listed with sane sizes = a proven copy. Put the stick somewhere that isn't next
to the Pi.

---

## Restoring from an off-box copy

Same as Chapter 10's restore test, from wherever the copy is. On a rebuilt Pi (databases
recreated empty per Chapter 03), copy the dumps over and load them:

```
zcat acore_auth-<stamp>.sql.gz        | sudo mysql acore_auth
zcat acore_characters-<stamp>.sql.gz  | sudo mysql acore_characters
zcat acore_playerbots-<stamp>.sql.gz  | sudo mysql acore_playerbots
```

Use the **same timestamp** for all three (they were dumped together and reference each
other). `acore_world` can be restored the same way, or simply regenerated by the server's
first boot. Your account and characters come back exactly as the backup saw them.

> **The validation loop caveat:** a true zero-deviation validation run rebuilds with fresh,
> empty databases — that's the point of the test. Restore your characters *after* the
> rebuilt realm is proven, and keep the restore out of the validation itself.

## ✅ Checkpoint

You're covered when:

- an off-box copy exists on **at least one** device that is not the Pi (desktop and/or USB),
- you've **verified** it once (the rsync listing / the plug-back-in `ls`), and
- you know the rule: **new off-box copy before any wipe.**

With Chapter 10's two on-box copies plus one of these, your realm's data lives on three or
four devices. That's a real backup posture — for a hobby realm on a Pi.
