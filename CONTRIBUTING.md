# Contributing

The most useful thing you can send us is **a problem we did not have**.

This guide is verified on one specific setup: a Raspberry Pi 5 (16 GB, ARM64) with an NVMe, building AzerothCore + Playerbots for solo play. It will be wiped and rebuilt from these instructions until it works in one clean run. But we only ever hit the problems *our* hardware and *our* choices produce. The rest arrive through you.

## Reporting a problem

Open an issue with:

1. **Which chapter** and which step number.
2. **The command you ran**, exactly.
3. **The complete error output.** Not a summary, not a screenshot of half of it. Paste the whole thing.
4. **Your hardware and OS**: board/CPU, architecture (`uname -m`), distro and version.

## If you already solved it

Even better. Open the issue anyway and include the fix. It goes into [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) **with credit to you**, and the relevant chapter gets a pointer to it.

## Improving a chapter

Pull requests welcome for clarity: a step that was ambiguous, a checkpoint that did not actually prove anything, a missing "what you should see". The bar for this guide is that someone who has never done it before can follow it without guessing.

Please do not submit:
- Links to game clients or any copyrighted Blizzard material.
- Steps you have not personally run. Untested instructions are how guides waste people's weekends, which is the entire thing this project exists to avoid.

## Style

Chapters follow the shape described in [docs/README.md](docs/README.md): what it is, why it matters, prerequisites, numbered steps, a checkpoint, and what to do when it fails. Match it.
