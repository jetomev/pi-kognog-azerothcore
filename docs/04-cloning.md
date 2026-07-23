# Chapter 04 — Cloning AzerothCore + the Playerbots fork

Now we get the server's source code. But not *plain* AzerothCore — the version with
Playerbots, which is a **fork** plus a **module**. Getting the right repositories and
branches here is the single most important correctness step in the whole guide.

> **Connect to the Pi first.** From your desktop:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```
> Everything in this chapter runs on the Pi (`tpgaming01 $`).

## What this is

Two clones:

1. A **fork** of AzerothCore that contains the core changes Playerbots needs.
2. The **mod-playerbots module**, cloned into that fork's `modules/` folder.

Both go on `/mnt/nvme` (the NVMe data disk, which we own as `tphome`, so no `sudo`).

## Why it matters

**Plain AzerothCore will not run Playerbots.** The module requires core-level hooks that
only exist in the fork. Clone upstream `azerothcore/azerothcore-wotlk` and the module
will not build. This is stated outright in the module's own README.

## ⚠ Get the source from the *current* location

The Playerbots project has **moved**. Most older guides and videos point at the original
personal repositories (`liyunfan1223/...`). Today the canonical, maintained source is the
**`mod-playerbots` GitHub organization**. Verified current at the time of writing:

| Piece | Repository | Branch |
|---|---|---|
| AzerothCore fork | `github.com/mod-playerbots/azerothcore-wotlk` | `Playerbot` (singular) |
| Playerbots module | `github.com/mod-playerbots/mod-playerbots` | `master` |

If a tutorial tells you to clone `liyunfan1223/...`, treat it as out of date and use the
`mod-playerbots` org instead. When in doubt, open the module's README on GitHub and use
whatever clone commands it currently shows — this project moves.

## Before you start

- Chapter 02 complete (`git` is installed).
- `/mnt/nvme` mounted and owned by your user (from Chapter 00).

## Steps

### 1. Clone the fork, then the module into it

The first clone pulls AzerothCore's full history (~1.3 GB) — a few minutes. We do a
**full** clone, not shallow, because the build reads git revision information.

```
tpgaming01 $ cd /mnt/nvme
tpgaming01 $ git clone https://github.com/mod-playerbots/azerothcore-wotlk.git --branch=Playerbot
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/modules
tpgaming01 $ git clone https://github.com/mod-playerbots/mod-playerbots.git --branch=master
```

The module **must** end up at `/mnt/nvme/azerothcore-wotlk/modules/mod-playerbots`. The
build discovers modules by scanning that `modules/` folder; a module cloned anywhere else
is simply ignored.

### 2. Verify the branches and the module location

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk
tpgaming01 $ echo "core branch : $(git branch --show-current)"
tpgaming01 $ cd modules/mod-playerbots
tpgaming01 $ echo "module branch: $(git branch --show-current)"
tpgaming01 $ echo "module path : $(pwd)"
```

## ✅ Checkpoint

Chapter 04 is done when:

- the core repo is on branch **`Playerbot`**,
- the module repo is on branch **`master`**, and
- the module is at **`/mnt/nvme/azerothcore-wotlk/modules/mod-playerbots`**.

(The exact commit hashes will differ from any shown here — these are actively developed
branches. The branch *names* and the module *path* are what matter.)

From here on, `/mnt/nvme/azerothcore-wotlk` is the **source root** referenced by every
remaining chapter.

## ⚠ If it went wrong

- **You cloned `azerothcore/azerothcore-wotlk` (upstream) by habit** — the module will
  fail to build later. Re-clone from the `mod-playerbots` fork.
- **The module is not in `modules/`** — the build will silently omit Playerbots and you
  will end up with a bot-less server. Confirm the path in Step 2.
- **`git clone` fails with a TLS/network error** — check the Pi has internet
  (`ping github.com`); retry. A partial clone can be removed (`rm -rf` the directory) and
  re-cloned safely.
