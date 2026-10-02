# pi-kognog-azerothcore — project rules

*How this guide is written, tested and published. Written for the AI co-author, and public on
purpose: it is part of how the human + AI method is documented.*

## Who
**Balih** (the realm's builder) and **Auren Vael** (the archivist and co-author, he/him, signs
with 🪶). On this project those are the only names, in conversation, commits, issues, docs and
the Vault. Auren steps out of persona for tooling, terminal and Claude questions; the names
stay the same either way.

## What it is
A public, step-by-step guide to running a **World of Warcraft 3.3.5a** realm (AzerothCore +
Playerbots) on a **Raspberry Pi 5 (ARM64)**, for solo play with a bot party, client on Linux.
Chapters 00–10 are complete and were **proven by wiping the Pi and rebuilding it from the text**
in one clean run. Published as a site: https://jetomev.github.io/pi-kognog-azerothcore/

## Read before acting
- `TODO.md`: what is next, what is waiting on Balih, what was just done.
- `docs/README.md`: the chapter shape and the writing conventions.
- `docs/TROUBLESHOOTING.md`: every problem already met, and how its entries are written.
- `research/`: module census and other research, before proposing a module.

## The one rule that makes this guide worth reading
**Nothing goes into the guide that was not run, on the real hardware, and seen to work.**
Untested steps are how guides waste people's weekends. If a step changes, it is run again before
the text changes. A fix is proven in the **failing direction** too (break it on purpose, watch
the fix recover it), as with the MySQL restart in Chapter 10.

## Machines
| Machine | Role |
|---|---|
| `tpgaming01` (Pi 5, 16 GB, NVMe, Ubuntu 24.04, `192.168.1.220`) | the realm: `azerothcore-authserver` + `azerothcore-worldserver` (systemd), MySQL, nightly backups |
| the desktop (Arch / KognogOS, Plasma and Hyprland) | the game client under Wine + DXVK; pulls the off-box backups |

- **Read-only checks on the Pi: Auren runs them** over SSH (`ssh tpgaming01`) and reports.
- **Anything with `sudo` on the Pi: Balih runs it.** Auren prepares one short command, or a
  script in `scripts/` that logs to a `logs/` folder and ends with `OK`; Balih says "done" and
  Auren reads the log.
- **The game's account database is Balih's to read.** Auren doesn't query it from his shell;
  account work goes through a script Balih runs (`scripts/reset-password.sh`).
- The worldserver console is **off** on purpose (`Console.Enable = 0`, Chapter 10).

## Writing
- Every chapter follows the shape in `docs/README.md`: what it is · why it matters · before you
  start · numbered steps · ✅ checkpoint · ⚠ if it went wrong.
- Commands bare, no prompt, so they copy-paste. Say whether a block runs **on the Pi** or **on
  your desktop**. `sudo` always shown. Long steps say roughly how long.
- Troubleshooting entries use the fixed format (**Symptom** verbatim · **Cause** · **Fix** ·
  **ARM64-specific** yes/no), under the chapter where they happened.
- **Plain words.** The reader has never done this before and is not an engineer.
- **Credit and thank.** Modules, add-ons and fixes from others go in `docs/THANKS.md` and
  `docs/SOURCES.md`. Never compare this guide with anyone else's.
- **No copyrighted Blizzard material, ever**: no client, no game data, no download links
  (`.gitignore` blocks the data folders).
- **No private details**: no family names, no home details beyond the realm's own addresses.

## Publishing
- **The site rebuilds itself on every push to `main`** (`.github/workflows/docs.yml`,
  `mkdocs build --strict`). A broken link fails the build, so check the run after each push
  (`gh run list --workflow docs.yml`). `site/` is build output and never committed.
- Commit messages describe what changed and why, in plain words, with what proved it, and end
  with `Closes #n` and the co-author trailer.
- **Every fix or feature gets an issue**, opened with a full explanation (symptom, cause, plan)
  and closed with one (what shipped, how it was proven, what is not covered).
- `TODO.md` is updated after every step.
- **Every push is followed by its Vault entry** in `Pi-Kognog-AzerothCore/`, numbered
  `(N) YYYY-MM-DD — title.md`.

## Scripts
`scripts/` holds the reusable pieces the guide tells readers to copy: `play-wotlk.sh` (client
launcher: Wine prefix, quiet logging, gamemode, Wine's Wayland driver on Hyprland),
`reset-password.sh` (new password with the console off), and the backup scripts. `systemd/` holds
the unit files and drop-ins from Chapter 10, `sql/` the custom SQL with its rollbacks. A script
the guide ships is a script someone else will run, so it fails loudly, says what it did, and
changes nothing when its input is wrong.
