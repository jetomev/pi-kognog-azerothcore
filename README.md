<div align="center">

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          P I - K O G N O G - A Z E R O T H C O R E           ║
║                                                              ║
║       Wrath of the Lich King  ·  3.3.5a  ·  Playerbots       ║
║       A solo realm, raised by hand on a Raspberry Pi 5       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

![Status: in progress](https://img.shields.io/badge/Status-Building%20live-3FA9E0.svg)
![Platform: Raspberry Pi 5](https://img.shields.io/badge/Platform-Raspberry%20Pi%205%20(ARM64)-7FD4F5.svg)
![Core: AzerothCore](https://img.shields.io/badge/Core-AzerothCore%203.3.5a-0B1A2A.svg)
![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)

</div>

---

## What this is

A **step-by-step, verified guide** to running your own **World of Warcraft: Wrath of the Lich King (3.3.5a)** server with **AzerothCore + Playerbots**, on a **Raspberry Pi 5 (ARM64)**, for solo play with a bot party.

It is written for someone who has never done this before. Every chapter assumes nothing, explains what each piece *is* before telling you to install it, and ends with a **checkpoint** so you know whether it worked before moving on.

## Why this guide exists

There are many AzerothCore tutorials. Almost all of them are **x86_64**, and most are transcribed from someone else's video.

This one is different in two ways:

1. **It targets ARM64.** Running AzerothCore, and especially **Playerbots**, on a Raspberry Pi is barely documented. The problems you hit there often have no answer anywhere. This guide is where those answers get written down.
2. **It is written live, then destroyed and rebuilt.** Nothing here is copied from a video. Each chapter is written as the step is actually performed on real hardware. Then the entire server is **wiped and built again from zero, following only this guide**, to find the steps that quietly depended on state we forgot we created. That loop repeats until a single clean run works start to finish, with no deviations.

> **Current status: not finished.** The realm is not up yet. Chapters appear as they are completed and verified. If a chapter is not listed below, it has not been written, because it has not been done.

## The guide

| # | Chapter | Status |
|---|---------|--------|
| 00 | [Provisioning the Pi (bare metal to ready host)](docs/00-provisioning.md) | ✅ done |
| 01 | [The client and extracting game data (maps, vmaps, mmaps)](docs/01-client-and-data.md) | ✅ done |
| 02 | [ARM64 build toolchain and dependencies](docs/02-build-toolchain.md) | ✅ done |
| 03 | [MariaDB and the three databases](docs/03-database.md) | ✅ done |
| 04 | [Cloning AzerothCore + the Playerbots fork](docs/04-cloning.md) | ✅ done |
| 05 | [Building (the long one)](docs/05-building.md) | ✅ done |
| 06 | Configuration: worldserver, authserver, playerbots | ☐ not started |
| 07 | First boot: accounts, GM, realm | ☐ not started |
| 08 | The client side: connecting and the realmlist | ☐ not started |
| 09 | Your bot party (tank, healer, two dps) | ☐ not started |
| 10 | Keeping it alive: services, backups, updates | ☐ not started |

**Optional:** **[Adding modules](docs/optional-modules.md)** — an auction-house bot (`mod-ah-bot`), quality-of-life modules, difficulty scaling, and the reusable pattern for adding any module. Tackled *after* the base realm works.

Alongside them: **[Troubleshooting](docs/TROUBLESHOOTING.md)** (every error we actually hit, with the fix) and **[Q&A](docs/QA.md)**.

## Prerequisite zero: the client

AzerothCore is a **3.3.5a server, client build 12340** (2010). This matters more than anything else on this page:

- **Modern retail WoW will not work.** It is many expansions past 3.3.5a.
- **WoW Classic will not work either.** The Classic lines are different builds, and Blizzard's current clients authenticate against Battle.net; they cannot be pointed at a private realm.
- **Battle.net does not distribute 3.3.5a.**

You need your own 3.3.5a (12340) client. Every map, model, and DBC file in this guide is extracted from it. Sourcing it is your responsibility and outside the scope of this guide; we do not link or distribute it.

## The hardware

| | |
|---|---|
| **Host** | Raspberry Pi 5, 16 GB RAM (`tpgaming01`, `192.168.1.220`) |
| **OS** | Ubuntu Server (ARM64), running from the microSD |
| **Storage** | 64 GB microSD (OS) + 500 GB NVMe on a HAT (game data, build, databases) |
| **Arch** | ARM64 / aarch64 |
| **Load target** | one human player + a 3-bot party (tank, healer, 2 dps) |

A note on scale, honestly: this sizing is for **solo play**. A 4-man party on a Pi 5 is comfortable. A populated world with dozens of bots is a different machine's problem; Playerbots is CPU-hungry and the Pi has four cores.

## Brand

Northrend, in a terminal.

| | Hex | Use |
|---|---|---|
| Abyss | `#05101B` | background |
| Deep navy | `#0B1A2A` | panels |
| Frost blue | `#3FA9E0` | primary accent |
| Ice | `#7FD4F5` | highlights |
| Rune glow | `#A8E6FF` | emphasis |
| Bone | `#E8F1F5` | text |

## Contributing

Hit a problem this guide did not cover? **Open an issue.** Solved it yourself? **Open an issue anyway and tell us how**, and it goes into the troubleshooting file with credit. See [CONTRIBUTING.md](CONTRIBUTING.md).

That last 5% (the problems we will never hit on our own hardware) only gets documented if people bring them back.

## Authors

A human and an AI, working as co-authors:

- **Balih Kognog** — direction, hardware, testing, the decision to wipe it all and do it again.
- **Auren Vael** (Claude, Anthropic) — architecture, drafting, and keeping the archive honest. 🪶

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

*World of Warcraft and Wrath of the Lich King are trademarks of Blizzard Entertainment. This project is not affiliated with, endorsed by, or connected to Blizzard in any way. [AzerothCore](https://www.azerothcore.org/) is an independent open-source project.*
