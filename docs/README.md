# The guide

Chapters are written **in the order they are performed**, on the real hardware, and only after the step actually worked. A chapter that does not exist yet is a step we have not done yet.

## How to read a chapter

Every chapter follows the same shape, so you always know where you are:

1. **What this is** — plain language. What the piece does and why it exists, before you are told to install anything.
2. **Why it matters** — what breaks later if you skip or fumble it.
3. **Before you start** — what must already be true (previous chapters, files, credentials).
4. **Steps** — numbered, one action each, with the command and what each flag means.
5. **✅ Checkpoint** — exactly what you should see if it worked. Do not continue past a failed checkpoint.
6. **⚠ If it went wrong** — the failures we actually hit here, and the fix. Links into [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for the long ones.

## Conventions

- Commands that must run **on the Pi** are marked `tphome03 $`.
- Commands that must run **on your desktop** are marked `desktop $`.
- Commands needing root are shown with `sudo` explicitly. Nothing is silently elevated.
- Paths are absolute wherever ambiguity is possible.
- Anything that takes more than a few minutes says so, with a rough duration, so you know the difference between "slow" and "hung".

## Chapter list

| # | Chapter | Status |
|---|---------|--------|
| 00 | Provisioning the Pi | ☐ |
| 01 | The client and extracting game data | ☐ |
| 02 | ARM64 build toolchain and dependencies | ☐ |
| 03 | MariaDB and the three databases | ☐ |
| 04 | Cloning AzerothCore + the Playerbots fork | ☐ |
| 05 | Building | ☐ |
| 06 | Configuration | ☐ |
| 07 | First boot | ☐ |
| 08 | The client side | ☐ |
| 09 | Your bot party | ☐ |
| 10 | Keeping it alive | ☐ |

## The validation loop

This guide is not finished when the server runs. It is finished when the guide **builds the server from nothing, unaided**.

1. Write the chapters live while doing it the first time.
2. Wipe the Pi back to a clean baseline image and rebuild, **following only the guide**.
3. Every deviation, every "oh, I also had to…", gets written down before continuing.
4. Repeat until one run completes start to finish with zero deviations.
5. Then publish, and let other people's hardware find the rest.
