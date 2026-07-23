# Chapter 06 — Configuration

The server binaries exist and the databases are empty and waiting. This chapter connects
the two: we move the extracted game data onto the Pi, then create and adjust the server
config files. Short and mostly mechanical — the heavy lifting was Chapters 01 and 05.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Most of this runs on the Pi (`tpgaming01 $`); the data transfer runs on your desktop
> (`desktop $`).

## What this is

Two jobs:

1. **Transfer the game data** (`dbc`, `maps`, `vmaps`, `mmaps`, `Cameras`) extracted on
   your desktop in Chapter 01 onto the Pi.
2. **Create the config files** the server reads, and point them at the data. The database
   settings are already correct because we used AzerothCore's default credentials in
   Chapter 03.

## Why it matters

`worldserver` will not start without its game data, and it won't find the data or the
databases without correct config. Get these right and first boot (Chapter 07) just works.

## Before you start

- Chapter 05 complete (server installed at `/mnt/nvme/azerothcore-wotlk/env/dist`).
- The Chapter 01 game data still on your desktop (this guide used `~/azeroth-extract/`).

## Steps

### 1. Transfer the game data to the Pi

On the **Pi**, make the destination folder:

```
tpgaming01 $ mkdir -p /mnt/nvme/azerothcore-wotlk/env/dist/data
```

Then, on your **desktop**, send the four data folders (plus `Cameras`) with `rsync` over
SSH. `rsync` must be installed on **both** machines (`sudo pacman -S rsync` on Arch,
`sudo apt install rsync` on the Pi — Ubuntu usually has it already):

```
desktop $ rsync -avhP -e "ssh -i ~/.ssh/id_ed25519_tpgaming" \
    ~/azeroth-extract/dbc ~/azeroth-extract/maps ~/azeroth-extract/vmaps \
    ~/azeroth-extract/mmaps ~/azeroth-extract/Cameras \
    tphome@192.168.1.220:/mnt/nvme/azerothcore-wotlk/env/dist/data/
```

- `rsync` is worth the install over plain `scp`: it is **resumable** (a dropped transfer
  picks up where it left off — handy for 3+ GB) and re-running only sends what's missing.
- The `mmaps` folder is ~3,700 small files, so the count climbs for a bit; a few minutes
  total is normal. This guide's transfer moved 3.23 GB at ~86 MB/s over wired LAN.

> **No `rsync`?** A dependency-free alternative streams a tar over SSH:
> ```
> desktop $ tar -C ~/azeroth-extract -cf - dbc maps vmaps mmaps Cameras \
>     | ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220 \
>       "tar -C /mnt/nvme/azerothcore-wotlk/env/dist/data -xf -"
> ```

Verify on the **Pi**:

```
tpgaming01 $ du -sh /mnt/nvme/azerothcore-wotlk/env/dist/data/*
```

You want `dbc` (~87M), `maps` (~295M), `vmaps` (~657M), `mmaps` (~2.1G), `Cameras` (~60K).

### 2. Create the config files

The install ships `.conf.dist` templates; the server reads `.conf` files you create from
them.

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/etc
tpgaming01 $ cp authserver.conf.dist authserver.conf
tpgaming01 $ cp worldserver.conf.dist worldserver.conf
tpgaming01 $ cp modules/playerbots.conf.dist modules/playerbots.conf
```

(We copy `playerbots.conf` now but leave its defaults; bots get configured in Chapter 09.)

### 3. Point `worldserver` at the data (and confirm the database settings)

Check the database lines and `DataDir`:

```
tpgaming01 $ grep -nE '^(LoginDatabaseInfo|WorldDatabaseInfo|CharacterDatabaseInfo|DataDir)' worldserver.conf
```

The three `DatabaseInfo` lines should already read
`127.0.0.1;3306;acore;acore;acore_{auth,world,characters}` — **no edit needed**, because
we created the databases with AzerothCore's default `acore`/`acore` credentials in
Chapter 03. (If you chose a custom database password there, change it in these three
lines and in `authserver.conf`'s `LoginDatabaseInfo`.)

The one change: set `DataDir` to the folder you filled in Step 1 (default is `"."`):

```
tpgaming01 $ sed -i 's|^DataDir = ".*"|DataDir = "/mnt/nvme/azerothcore-wotlk/env/dist/data"|' worldserver.conf
tpgaming01 $ grep -n '^DataDir' worldserver.conf
```

## ✅ Checkpoint

Chapter 06 is done when:

- `.../env/dist/data/` contains `dbc`, `maps`, `vmaps`, `mmaps`, `Cameras`,
- `authserver.conf`, `worldserver.conf`, and `modules/playerbots.conf` exist, and
- `worldserver.conf` has `DataDir` pointing at the data folder and the three
  `DatabaseInfo` lines pointing at the `acore` databases.

Nothing needs to be running yet — that's Chapter 07.

## ⚠ If it went wrong

- **`rsync: command not found`** — install it on both ends (Step 1), or use the `tar`
  fallback.
- **`Connection closed` right after a big transfer** — if it happens on a *second* SSH
  command immediately after `rsync` finishes, it's usually the Pi briefly busy flushing
  the writes to disk. The transfer itself already completed; just verify with `du` on the
  Pi. Harmless.
- **`DataDir` still `"."`** — the `sed` did not match. Open `worldserver.conf`, find the
  `DataDir` line, and set it by hand to the absolute path of your data folder.
