# Sources

Every external source this guide leaned on, with an honest note on each — what it's good
for, and where it's dated or needs care. This list **grows as the guide grows**; a source
is added the chapter it's actually used.

For the human thank-you to the people and projects behind these, see
**[THANKS.md](THANKS.md)**.

## Foundations (the whole guide rests on these)

| Source | Author / Maintainer | Link | Note |
|---|---|---|---|
| **AzerothCore** | AzerothCore project | https://www.azerothcore.org · https://www.azerothcore.org/wiki | The core we build. Excellent reference, but **x86-first** — almost nothing here is written for ARM64, which is exactly the gap this guide fills. As of Sept 2024 it requires **MySQL 8.0+** (MariaDB dropped). |
| **mod-playerbots (fork + module)** | `mod-playerbots` org (orig. liyunfan1223) | https://github.com/mod-playerbots/mod-playerbots | The Playerbots fork and module — the **correct current source**. Clone the **`Playerbot`** core branch + **`master`** module branch. Not the old `liyunfan1223` repos most tutorials still point at. Its extractor produces **v19** mmaps (upstream is v20 — they are not interchangeable). |
| **ChromieCraft — downloads** | ChromieCraft | https://chromiecraft.com/en/downloads/ | Where the reference **3.3.5a (12340)** client was sourced. Clean private-server client (`Wow.exe`, no launcher). Sourcing a client is the reader's responsibility; we neither link nor host game data. |

## Chapter 08 — the Linux client

| Source | Author | Link | Note |
|---|---|---|---|
| **MangosRumors — How to run WoW on Linux** | MangosRumors | https://www.mangosrumors.org/how-to-run-wow-on-linux/ | ⚠ **Dated (May 2020).** Its whole method is `wine Wow.exe` + optional `SET gxApi "OpenGL"`. Fine as a **"does bare Wine even run it?"** smoke test — and it does — but the OpenGL advice is now the *slow* path. Prefer d3d9 + DXVK. |
| **WoW 3.3.5a on Linux: Wine + DXVK (gist)** | sebyx07 | https://gist.github.com/sebyx07/e14b8d64e85e13162db3748ea20caea2 | ✅ **Current (Jan 2026).** The modern recipe we recommend for tier 2: win64 prefix, **DXVK 2.5.3**, keep `gxApi "d3d9"` (OpenGL bypasses DXVK), launch with `gamemoderun`. |
| **Warmane forum — 3.3.5a on CachyOS/Arch** | Warmane community | https://forum.warmane.com/showthread.php?t=484207 | Community Arch/CachyOS play notes. Useful for distro-specific gotchas (KDE stealing shortcuts, Wine zombie processes after exit). |
| **WineHQ** | WineHQ project | https://www.winehq.org | The compatibility layer itself. Reference tested: `wine-11.13` Staging. |
| **DXVK** | Philip Rebohle (doitsujin) | https://github.com/doitsujin/dxvk | D3D9→Vulkan translation; the tier-2 performance layer. |
| **Lutris** | Lutris project | https://lutris.net | Optional managed runner (Warmane WoW install script exists). No raw-perf gain over a hand-made prefix for 3.3.5a, but tidier to manage. |

## Chapter 09 — the bot party

| Source | Author | Link | Note |
|---|---|---|---|
| **mod-playerbots — Playerbot Commands (wiki)** | `mod-playerbots` org | https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands | ✅ The **authoritative** in-game command reference. Confirms the `.playerbots bot addclass` / `.playerbots bot add` syntax and the rndbot-vs-altbot distinction. When in doubt, this page over any tutorial. |

---

*Spotted a better or more current source, or one we should flag? Open an issue — see
[CONTRIBUTING.md](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/CONTRIBUTING.md).*
