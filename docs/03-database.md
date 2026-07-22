# Chapter 03 — MariaDB and the three databases

The server needs somewhere to keep everything: accounts, characters, and the game world
itself. That is three databases inside one MariaDB server. Here we install MariaDB,
create those databases and the user the server logs in as, and confirm it all works.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything in this chapter runs on the Pi (`tpgaming01 $`).

## What this is

AzerothCore uses three databases:

| Database | Holds |
|---|---|
| `acore_auth` | accounts and the realm list |
| `acore_characters` | your characters — and your bots |
| `acore_world` | the game world: creatures, quests, items, spawns |

We use **MariaDB** (from Ubuntu's own repositories) as the database server. This is the
one deliberate divergence from AzerothCore's Ubuntu 24.04 wiki, which points at an
external MySQL 8.4 repo — MariaDB is simpler, ARM64-native, needs no third-party repo,
and AzerothCore fully supports it.

## Why it matters

Nothing about the server runs without these. The world database in particular is huge
and detailed; getting the databases and login user right now means the server can, on
first boot, import its schema and start filling them.

## Before you start

- Chapter 02 complete (build toolchain installed).
- You are SSH'd into the Pi.

## Steps

### 1. Install MariaDB

```
tpgaming01 $ sudo apt install -y mariadb-server
tpgaming01 $ sudo systemctl enable --now mariadb
tpgaming01 $ systemctl status mariadb --no-pager | head -4
tpgaming01 $ mariadb --version
```

`enable --now` both starts it and sets it to start on every boot. You should see
`active (running)` and a version like `10.11.x`.

> **Where the data lives:** this keeps MariaDB in its default location,
> `/var/lib/mysql`, which is on the microSD. For a solo server (one player, a few bots)
> the write volume is light, so this is fine. Moving the data directory to the NVMe for
> heavier use or long-term SD longevity is covered as an optimization in Chapter 10.

### 2. Create the databases and the server user

Ubuntu's MariaDB is already reasonably locked down out of the box — `root` authenticates
via the unix socket (only reachable through `sudo`, no password), there are no anonymous
users or `test` database, and it binds to localhost. So there is no
`mysql_secure_installation` ritual to perform; we go straight to creating what
AzerothCore needs.

Paste this whole block. It is AzerothCore's own create script — user `acore`, password
`acore`, the three databases in UTF8MB4:

```
tpgaming01 $ sudo mariadb <<'SQL'
DROP USER IF EXISTS 'acore'@'localhost';
CREATE USER 'acore'@'localhost' IDENTIFIED BY 'acore' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
CREATE DATABASE IF NOT EXISTS `acore_world` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_characters` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_auth` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `acore_world` . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_characters` . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_auth` . * TO 'acore'@'localhost' WITH GRANT OPTION;
SQL
```

> **About the `acore`/`acore` password.** It is weak, and here that is an accepted
> trade-off: MariaDB listens only on localhost, the firewall blocks the port anyway, and
> this is a solo server. Using AzerothCore's default also means **zero** credential edits
> in Chapter 06. If you want a strong password, change it in the `CREATE USER` line above
> and remember to set the same one in the three server config files in Chapter 06.

### 3. Verify

```
tpgaming01 $ sudo mariadb -e "SHOW DATABASES;"
tpgaming01 $ mariadb -u acore -pacore -e "SHOW DATABASES;"
tpgaming01 $ sudo ss -tlnp | grep 3306
```

- The first lists all databases including the three `acore_*`.
- The second logs in **as the `acore` user** (proving the user and its grants work) and
  should show exactly `acore_auth`, `acore_characters`, `acore_world`, and
  `information_schema` — not the system databases, because `acore` is scoped to its own.
- `ss` should show `127.0.0.1:3306` — bound to localhost, not `0.0.0.0`.

## ✅ Checkpoint

Chapter 03 is done when:

- `mariadb --version` shows a running 10.11.x server,
- the `acore` user can log in with `mariadb -u acore -pacore` and sees its three
  databases, and
- the databases are **empty**. That is correct — they are populated automatically on
  first boot in Chapter 07.

## ⚠ If it went wrong

- **`Access denied for user 'acore'@'localhost'`** on the verify step — the `CREATE USER`
  or `GRANT` lines did not all run. Re-paste the Step 2 block; it is safe to run again
  (it drops and recreates the user, and the databases use `IF NOT EXISTS`).
- **`ss` shows `0.0.0.0:3306`** — MariaDB is listening on all interfaces. On Ubuntu's
  default config it should be localhost; if not, set `bind-address = 127.0.0.1` in
  `/etc/mysql/mariadb.conf.d/50-server.cnf` and restart MariaDB. (Even if it did, the
  firewall from Chapter 00 blocks the port from outside.)
