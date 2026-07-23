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

- Commands that must run **on the Pi** are marked `tpgaming01 $`.
- Commands that must run **on your desktop** are marked `desktop $`.
- Commands needing root are shown with `sudo` explicitly. Nothing is silently elevated.
- Paths are absolute wherever ambiguity is possible.
- Anything that takes more than a few minutes says so, with a rough duration, so you know the difference between "slow" and "hung".

## Connecting to your server

Every chapter from 02 onward runs **on the Pi**, so each one opens with the same
reminder: get an SSH session first. From your desktop:

```
ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
```

(Substitute your key path and the static IP you set in Chapter 00.) Enter your key
passphrase; you should land at `tphome@tpgaming01:~$`. A graphical SSH client such as
**Termius** works too — point it at the same host, user, and key. If the connection is
refused, confirm the Pi is powered on and reachable (`ping 192.168.1.220`); if it asks
for a password instead of the key, see the `Permission denied (publickey)` entry in
[TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Chapter list

| # | Chapter | Status |
|---|---------|--------|
| 00 | [Provisioning the Pi](00-provisioning.md) | ✅ done |
| 01 | [The client and extracting game data](01-client-and-data.md) | ✅ done |
| 02 | [ARM64 build toolchain and dependencies](02-build-toolchain.md) | ✅ done |
| 03 | [MariaDB and the three databases](03-database.md) | ✅ done |
| 04 | [Cloning AzerothCore + the Playerbots fork](04-cloning.md) | ✅ done |
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
