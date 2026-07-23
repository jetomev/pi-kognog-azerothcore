# Chapter 05 — Building

The long one. Here we compile AzerothCore, with the Playerbots module baked in, into two
programs: `authserver` and `worldserver`. On a Raspberry Pi 5 this took about **75
minutes**. Plan for it — start it, walk away, come back.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything in this chapter runs on the Pi (`tpgaming01 $`).

## What this is

Turning the source you cloned in Chapter 04 into runnable server binaries. We compile
with **Clang**, statically linking the game scripts and the Playerbots module directly
into `worldserver`, and install the result into
`/mnt/nvme/azerothcore-wotlk/env/dist`.

## Why it matters

This is where the abstract "source code" becomes an actual server. It is also the step
most likely to hit a Raspberry-Pi-specific wall — memory pressure — so we prepare for
that first.

## Before you start

- Chapter 02 (toolchain) and Chapter 04 (source cloned to `/mnt/nvme/azerothcore-wotlk`)
  complete.
- You are SSH'd into the Pi.

### Build reference machine

| | |
|---|---|
| Host | Raspberry Pi 5, 16 GB RAM, 4 cores |
| OS | Ubuntu Server 24.04 (arm64), kernel 6.8 |
| Compiler | Clang 18.1.3, `-j4` |
| Swap | 8 GB (added in Step 1) |
| **Build time** | **~75 minutes** (`real 74m57s`) |

A Pi with less RAM (8 GB or 4 GB) will lean harder on swap and build slower; the swap
step below is not optional for those.

## Steps

### 1. Add swap (do not skip on a Pi)

Ubuntu Server ships with **no swap**. A parallel C++ build can briefly spike past
available RAM, and with no swap that is an instant out-of-memory kill — losing the whole
build. An 8 GB swapfile turns that cliff into a soft landing, and it protects the running
server later too. We put it on the NVMe (fast, spares the microSD).

```
tpgaming01 $ sudo fallocate -l 8G /mnt/nvme/swapfile
tpgaming01 $ sudo chmod 600 /mnt/nvme/swapfile
tpgaming01 $ sudo mkswap /mnt/nvme/swapfile
tpgaming01 $ sudo swapon /mnt/nvme/swapfile
tpgaming01 $ echo '/mnt/nvme/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
tpgaming01 $ echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
tpgaming01 $ sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

`free -h` should now show `Swap: 8.0Gi`. `swappiness=10` means the kernel prefers RAM and
only spills to swap under real pressure.

### 2. Configure with CMake

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk
tpgaming01 $ mkdir -p build && cd build
tpgaming01 $ cmake .. \
    -DCMAKE_INSTALL_PREFIX=/mnt/nvme/azerothcore-wotlk/env/dist \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DWITH_WARNINGS=0 \
    -DTOOLS_BUILD=none \
    -DSCRIPTS=static \
    -DMODULES=static \
    -DCMAKE_BUILD_TYPE=Release
```

- `TOOLS_BUILD=none` — we extracted game data on the desktop (Chapter 01); no need to
  build the extractors again on the Pi.
- `SCRIPTS=static` / `MODULES=static` — compile the scripts **and Playerbots** into the
  binary.
- `CMAKE_BUILD_TYPE=Release` — leaner binary and, importantly, a **smaller memory spike
  at link time** than the default (which carries debug symbols). On a Pi that matters.
- No `-DNOJEM=1` needed here. The Pi's GCC-13 `libstdc++` compiles the bundled jemalloc
  fine (unlike a bleeding-edge desktop GCC — see the Chapter 01 troubleshooting entry).

**Before building, confirm in the output** that the "Modules configuration" section lists
`mod-playerbots`. If it does not, the module will not be in your server — stop and check
Chapter 04.

### 3. Build (inside `screen`)

The build runs for over an hour, so run it inside `screen` — that keeps it alive even if
your SSH connection drops.

```
tpgaming01 $ screen -S build
```

Inside the screen session:

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/build
tpgaming01 $ { time make -j4 ; } 2>&1 | tee /mnt/nvme/build.log
```

Then **detach** so it survives a disconnect: press `Ctrl-A`, release, then `D`.

Check on it any time:
- reattach: `screen -r build` (detach again with `Ctrl-A` `D`)
- peek: `tail -n 20 /mnt/nvme/build.log`
- memory: `free -h`

Success looks like `[100%] Built target worldserver` and a `real ...m...s` timing line.

### 4. Install

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/build
tpgaming01 $ make install
```

This copies the binaries and config templates into `env/dist`. Verify:

```
tpgaming01 $ ls -lh /mnt/nvme/azerothcore-wotlk/env/dist/bin/
tpgaming01 $ ls /mnt/nvme/azerothcore-wotlk/env/dist/etc/
tpgaming01 $ ls /mnt/nvme/azerothcore-wotlk/env/dist/etc/modules/
```

## ✅ Checkpoint

Chapter 05 is done when:

- the build reached `[100%] Built target worldserver` with no errors,
- `env/dist/bin/` contains **`authserver`** and **`worldserver`** (worldserver is ~50 MB),
- `env/dist/etc/` has `authserver.conf.dist` and `worldserver.conf.dist`, and
- `env/dist/etc/modules/` has **`playerbots.conf.dist`**.

The install root `/mnt/nvme/azerothcore-wotlk/env/dist` is where the server *runs* from —
Chapters 06 and 07 work here.

## ⚠ If it went wrong

- **The build stopped with `Killed` / `c++: fatal error: Killed signal terminated
  program`** — that is an out-of-memory kill. Make sure swap is on (Step 1), and if it
  still happens, rebuild with fewer parallel jobs: `make -j2` (or `-j1`). Slower, but it
  will not run out of memory. See the Troubleshooting entry.
- **`mod-playerbots` was not in the CMake modules list** — the module is not where the
  build looks. Confirm it is at `/mnt/nvme/azerothcore-wotlk/modules/mod-playerbots`
  (Chapter 04), then re-run CMake.
- **Compiler errors** deep in the build — you may be on a mismatched core/module branch.
  Confirm the core is on `Playerbot` and the module on `master` (Chapter 04).
