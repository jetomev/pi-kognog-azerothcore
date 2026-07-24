# Chapter 03 — MySQL and the four databases

The server needs somewhere to keep everything: accounts, characters, the game world,
and — because we're running Playerbots — the bots' own data. That's four databases inside
one MySQL server. Here we install MySQL, create those databases and the user the server
logs in as, and confirm it works.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything in this chapter runs on the Pi (`tpgaming01 $`).

## What this is

AzerothCore uses three databases, and the **Playerbots module adds a fourth**:

| Database | Holds |
|---|---|
| `acore_auth` | accounts and the realm list |
| `acore_characters` | your characters |
| `acore_world` | the game world: creatures, quests, items, spawns |
| `acore_playerbots` | Playerbots' own data (bot state, guild names, etc.) |

## Why MySQL 8.0 (and not MariaDB)

**AzerothCore requires MySQL 8.0 or newer, and dropped MariaDB support in September 2024.**
This is not optional — the worldserver checks the database version at startup and refuses
to run against MariaDB (which it reads as a "5.5.5" version and rejects). We use **MySQL
8.0 from Ubuntu's own repositories** — no external repo needed, and it matches the MySQL
8.0 client library the server was built against in Chapter 02.

> If you followed an older guide (or an earlier version of this one) that used MariaDB,
> that's the trap: it installs and creates databases fine, then the server won't boot.
> See the Troubleshooting entry "does not support MySQL versions below 8.0."

## Why the fourth database

Standard AzerothCore has three databases. **Playerbots needs `acore_playerbots` too.** If
you create only three, the worldserver imports the world successfully and then **crashes
(segfault)** when the Playerbots module tries to open a database that doesn't exist. We
create all four up front.

## Before you start

- Chapter 02 complete (build toolchain, including the MySQL client library).
- You are SSH'd into the Pi.

## Steps

### 1. Install MySQL 8.0

```
tpgaming01 $ sudo apt install -y mysql-server
tpgaming01 $ sudo systemctl enable --now mysql
tpgaming01 $ sudo systemctl status mysql --no-pager | head -3
tpgaming01 $ mysql --version
```

You should see `active (running)` and a version like `8.0.x`.

> **Where the data lives:** this keeps MySQL in its default location, `/var/lib/mysql`,
> on the microSD. For a solo server the write volume is light. Moving the data directory
> to the NVMe is covered as an optimization in Chapter 10.

### 2. Create the four databases and the server user

Ubuntu's MySQL authenticates `root` via the unix socket (reachable only through `sudo`,
no password), so there's no `mysql_secure_installation` ritual needed. Paste this whole
block — it is AzerothCore's create script **plus** the Playerbots database:

```
tpgaming01 $ sudo mysql <<'SQL'
DROP USER IF EXISTS 'acore'@'localhost';
CREATE USER 'acore'@'localhost' IDENTIFIED BY 'acore' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
CREATE DATABASE IF NOT EXISTS `acore_world`      DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_characters` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_auth`       DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_playerbots` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `acore_world`      . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_characters` . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_auth`       . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_playerbots` . * TO 'acore'@'localhost' WITH GRANT OPTION;
SQL
```

> **About the `acore`/`acore` password.** Weak, and acceptable here: MySQL listens only on
> localhost, the firewall blocks the port, and this is a solo server. Using AzerothCore's
> default also means zero credential edits in Chapter 06. For a strong password, change it
> in the `CREATE USER` line and in the four `DatabaseInfo` lines in Chapter 06 (and the
> Playerbots database line in `playerbots.conf`).

### 3. Verify

```
tpgaming01 $ sudo mysql -e "SHOW DATABASES;"
tpgaming01 $ mysql -u acore -pacore -e "SHOW DATABASES;"
tpgaming01 $ sudo ss -tlnp | grep 3306
```

- The first lists all four `acore_*` databases.
- The second logs in **as `acore`** (proving user and grants) and shows its four databases.
- `ss` shows `127.0.0.1:3306` — localhost only (MySQL also opens `33060` for its X
  protocol, also localhost; both are firewalled regardless).

### 4. (Optional) Disable the binary log

Unlike MariaDB, **MySQL 8.0 enables the binary log by default**, and it grows over time —
on a small disk that adds up. AzerothCore does not need it. To turn it off:

```
tpgaming01 $ echo -e "[mysqld]\nskip-log-bin" | sudo tee /etc/mysql/mysql.conf.d/zz-acore.cnf
tpgaming01 $ sudo systemctl restart mysql
```

(Skip this if you want point-in-time recovery and don't mind the disk usage.)

## ✅ Checkpoint

Chapter 03 is done when `mysql --version` shows 8.0.x, the `acore` user logs in with
`mysql -u acore -pacore` and sees its **four** databases, and they are all **empty** —
that's correct; the servers populate them on first boot in Chapter 07.

## ⚠ If it went wrong

- **You installed MariaDB** (an earlier plan) — the server won't boot later
  (`does not support MySQL versions below 8.0`). Remove MariaDB and install MySQL as
  above. See Troubleshooting for the clean removal (do **not** blanket-`rm -rf /etc/mysql`
  while `mysql-common` is installed — it breaks the MySQL install).
- **`Access denied for user 'acore'@'localhost' to database 'acore_playerbots'`** at first
  boot — you created only three databases. Add the fourth (Step 2 is safe to re-run).
