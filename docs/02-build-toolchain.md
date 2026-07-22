# Chapter 02 — ARM64 build toolchain and dependencies

A short chapter: install everything needed to *compile* AzerothCore on the Pi, and
confirm the versions are new enough. No source is built yet — we are stocking the
workshop before the work.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything in this chapter runs on the Pi (`tpgaming01 $`). A graphical client such as
> Termius works too — same host, user, and key.

## What this is

The compilers, build system, and libraries AzerothCore needs. We install them from
Ubuntu's own repositories, verify the versions clear AzerothCore's minimums, and stop
there.

> **This is the *native-build* base guide.** We build AzerothCore directly on Ubuntu and
> will run it as system services. A containerized (Docker) version is planned as a
> separate fork later, with its own validation. If you want the simplest path that just
> works, you are on it.

## Why it matters

If the toolchain is incomplete or too old, the build in Chapter 05 fails partway
through — often with a cryptic compiler or CMake error. Installing the full, correct set
now turns that long build into an uneventful one.

## Before you start

- Chapter 00 complete (a provisioned, reachable Pi).
- You are SSH'd into the Pi.

## Steps

### 1. Install the toolchain and dependencies

This is the AzerothCore-recommended package set for Ubuntu 24.04, plus the MySQL/MariaDB
**client** development headers the build links against:

```
tpgaming01 $ sudo apt update
tpgaming01 $ sudo apt install -y git cmake make gcc g++ clang \
    libssl-dev libbz2-dev libreadline-dev libncurses-dev \
    libboost-all-dev default-libmysqlclient-dev
```

Notes:

- **`libboost-all-dev`** is broad (it pulls in more of Boost than AzerothCore strictly
  needs, ~1.5 GB of packages including some MPI/LLVM extras). It is the simplest choice
  and what the wiki recommends; trimming it is an optimization for later, not now.
- **`default-libmysqlclient-dev`** installs the client library the server build links
  against. On Ubuntu 24.04 this resolves to **MySQL 8.0's** client (`libmysqlclient21`),
  which builds AzerothCore fine regardless of which database *server* you run.

> **Deliberate divergence from the wiki:** AzerothCore's 24.04 instructions add Oracle's
> external APT repo and install **MySQL 8.4**. For this easy-install base guide we do
> **not** do that here. We install only the client headers now, and in Chapter 03 we use
> **MariaDB** from Ubuntu's own repositories — no third-party repo, no GPG keys, ARM64
> native, and fully supported by AzerothCore. One less thing to break.

### 2. Verify the versions

```
tpgaming01 $ gcc --version | head -1
tpgaming01 $ clang --version | head -1
tpgaming01 $ cmake --version | head -1
tpgaming01 $ dpkg -s libboost-dev | grep '^Version'
tpgaming01 $ openssl version
```

## ✅ Checkpoint

Your versions should meet or exceed these. From this guide's Pi (Ubuntu 24.04 on a
Raspberry Pi 5):

| Tool | Installed here | AzerothCore minimum |
|---|---|---|
| GCC | 13.3.0 | tested range (13 is well inside it) |
| Clang | 18.1.3 | alternative compiler |
| CMake | 3.28.3 | ≥ 3.16 |
| Boost | 1.83.0 | ≥ 1.74 |
| OpenSSL | 3.0.13 | ≥ 3.0 |

If all five clear their minimums, Chapter 02 is done. Note that the Pi's **GCC 13** is
much older than a bleeding-edge desktop's — which is a good thing here; it sits squarely
in AzerothCore's tested range and avoids new-compiler breakage.

## ⚠ If it went wrong

This chapter is usually uneventful — it is just `apt`. If a package is not found, run
`sudo apt update` first. If `apt` reports held or broken packages, resolve those before
continuing (`sudo apt --fix-broken install`). Nothing here was ARM64-specific; the same
packages exist for `arm64` as for `amd64`.
