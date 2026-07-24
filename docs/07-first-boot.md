# Chapter 07 — First boot

The payoff. When `worldserver` starts for the first time, it fills the empty databases,
loads the world, and hands you a live console. By the end of this chapter you have a
running realm, an admin account, and the ambient bot population tuned to something a Pi
can carry.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything here runs on the Pi (`tpgaming01 $`).

## What this is

Starting the server for the first time. On first run, `worldserver`'s built-in updater
imports the entire schema into the four databases (auth, characters, world, playerbots),
then loads the game data you placed in Chapter 06 and initializes the world.

## Why it matters

This is the moment everything so far becomes an actual server. It's also where two
Playerbots-specific things show up if earlier chapters weren't exactly right — so if you
hit them, they're covered below and in Troubleshooting.

## Before you start

- Chapters 03 (MySQL, **four** databases) and 06 (config + game data) complete.
- You are SSH'd into the Pi.

## Steps

### 1. First boot (inside `screen`)

The first import can take **10–30 minutes** on a Pi — it writes the whole world into
MySQL. Run it in `screen` so a dropped SSH connection can't kill it.

```
tpgaming01 $ screen -S world
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/bin
tpgaming01 $ ./worldserver
```

*What you'll see, in order:*
1. The AzerothCore banner. (A harmless `Can't set process priority class ... Permission
   denied` line — ignore it; the server just can't raise its own scheduling priority as a
   non-root user.)
2. `Database 'acore_world' is empty, auto populating it...` and a long stream of
   `Applying update ...` lines — the whole world importing. Let it run.
3. Data loading: maps, spells, creatures, and the Playerbots setup.
4. Finally `World initialized`, bot stats, and a console prompt (`AC>`).

**Watch the load for two things** (both should be *absent* if Chapters 01/03 were right):
- No `Access denied ... 'acore_playerbots'` (that's the missing fourth database — Chapter
  03).
- No `MMAP: … was built with generator v20, expected v19` (that's the wrong mmap version —
  Chapter 01). If you see these, jump to Troubleshooting; otherwise carry on.

### 2. Create your GM account

At the `AC>` console prompt (pick your own name and password — this is your *game* login):

```
AC> account create BALIH changeme123
AC> account set gmlevel BALIH 3 -1
```

- `account create <name> <password>` — your login account.
- `account set gmlevel <name> 3 -1` — grants **GM level 3 (full admin)** on **all realms**
  (`-1`): summon bots, teleport, spawn, everything.

You should see `Account created: BALIH` and a confirmation of the security level.

### 3. Tune the ambient bots

By default Playerbots keeps **500 random bots** online — far too many for a Pi (the
`Update time diff` climbs to 40+ ms with nobody even playing). These are *ambient
population*, separate from your personal party (Chapter 09). Bring them down.

Stop the server first (in the console):

```
AC> server shutdown 1
```

Then edit `playerbots.conf`:

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/etc/modules
tpgaming01 $ sed -i 's/^AiPlayerbot.MinRandomBots = .*/AiPlayerbot.MinRandomBots = 20/' playerbots.conf
tpgaming01 $ sed -i 's/^AiPlayerbot.MaxRandomBots = .*/AiPlayerbot.MaxRandomBots = 40/' playerbots.conf
```

- ~40 keeps the world feeling alive while leaving the Pi headroom (roughly 10× less load
  than 500).
- Want it silent and purely your own party? Set `MaxRandomBots = 0`.
- Want more life? Raise it and watch the `Update time diff` — keep the mean comfortably
  under ~100 ms.

Restart to apply:

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/bin
tpgaming01 $ ./worldserver
```

The population settles toward your new number over a few minutes, and the tick diff falls.

## ✅ Checkpoint

Chapter 07 is done when:

- `worldserver` reaches the `AC>` console with no `acore_playerbots` or `mmap version`
  errors,
- bots are actually **moving** (questing, grinding, flying — proof the navmeshes load),
- your GM account exists at level 3, and
- the random bot count is tuned down.

You now have a running realm. Next chapter: point your client at it and walk in.

## ⚠ If it went wrong

- **`AzerothCore does not support MySQL versions below 8.0` / `Found server version:
  5.5.5-...-MariaDB`** — you're on MariaDB. Migrate to MySQL 8.0 (Chapter 03 / Troubleshooting).
- **`Access denied ... 'acore_playerbots'` then `Segmentation fault`** — the fourth
  database is missing. Create it (Chapter 03, Step 2) and retry.
- **`MMAP: … generator v20, expected v19`** and bots frozen/failing to move — your mmaps
  were built with upstream's extractor instead of the fork's. Regenerate them with the
  fork's `mmaps_generator` (Chapter 01 / Troubleshooting).
- **Import is very slow** — normal on a Pi; the first world import is the long part and
  only happens once.
