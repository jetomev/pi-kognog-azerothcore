# Optional — Adding modules

**This is an optional section, done *after* the base server works.** The base guide
(Chapters 00–10) gets you a running Playerbots realm and nothing else. Once that is
proven, modules let you add features — an active auction house, quality-of-life tweaks,
difficulty scaling, and more.

Modules are the reason to add them one at a time and test: every module you add is more
build time, more config, and more surface for a bug. The base realm should work first.

> **Verify before you clone.** The AzerothCore module ecosystem moves — repos get
> renamed, branches change, some go unmaintained. Before adding any module below, open
> its GitHub page and use the clone/branch it currently shows, exactly as we did for
> Playerbots in Chapter 04. The names here are a starting point, not a guarantee.

## The pattern (how to add *any* module)

Every module follows the same shape. This is the reusable recipe:

1. **Clone it into the source tree's `modules/` folder:**
   ```
   tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/modules
   tpgaming01 $ git clone <module-repo-url>
   ```
   It must land at `/mnt/nvme/azerothcore-wotlk/modules/mod-<name>`.

2. **Reconfigure and rebuild.** This is an *incremental* build — only the new module
   compiles and `worldserver` relinks; everything already built is cached, so it takes
   minutes, not hours:
   ```
   tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/build
   tpgaming01 $ cmake .. -DAPPS_BUILD=none -DTOOLS_BUILD=none -DSCRIPTS=static -DMODULES=static
   tpgaming01 $ make -j4 && make install
   ```
   Confirm the module appears in the cmake "Modules configuration" list before building.

3. **Apply its config.** Modules ship a `<name>.conf.dist` in the install's `etc/modules/`
   folder. Copy it to `.conf` and edit as needed:
   ```
   tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/etc/modules
   tpgaming01 $ cp mod_<name>.conf.dist mod_<name>.conf
   ```

4. **Database:** most modules bring their own SQL. AzerothCore's updater applies it
   automatically on the next `worldserver` start — no manual import needed (the updater
   is covered in Chapter 07).

Each module added below will get its exact repo, branch, config, and any gotchas
documented *as we add it and test it* — not before.

## Candidate modules for a solo + Playerbots realm

Curated from the AzerothCore GitHub org, filtered for what actually helps solo play with
a bot party. Star counts are a rough popularity signal, not an endorsement.

### Tier 1 — genuinely improves solo play

| Module | What it does | Notes |
|---|---|---|
| `mod-ah-bot` | Populates the auction house with buyable/sellable items | The reason to bother, on a low-pop realm. **First one we'll add.** |
| `mod-autobalance` | Scales dungeon/raid difficulty to your actual party size | Powerful but cuts both ways with bots — a full bot party reads as a group and can make content *harder*. Needs tuning. |
| `mod-aoe-loot` | Loot every nearby corpse in one action | Big quality-of-life when grinding solo. |
| `mod-learn-spells` | Auto-learns class spells on level-up | No more trips to the trainer. |

### Tier 2 — quality of life

| Module | What it does | Notes |
|---|---|---|
| `mod-transmog` | Change gear appearance (transmogrification) | Most popular AC module. Pure cosmetics. |
| `mod-npc-buffer` | An NPC that buffs you on demand | Convenience. |
| `mod-solocraft` | Stat-scales you to handle group content solo | **Alternative** to autobalance — don't run both. May be redundant with a bot party. |
| `mod-dynamic-xp` / `mod-individual-xp` | Control leveling speed | Blizzlike, faster, or per-account. |

### Tier 3 — situational / thematic

| Module | What it does | Notes |
|---|---|---|
| `mod-solo-lfg` | Queue dungeons as a solo player | Bots already fill your group, so situational. |
| `mod-progression-system` | ChromieCraft-style phased content unlocking | Matches this guide's client origin, but deliberately restricts progression. Advanced taste. |
| `mod-npc-beastmaster` | Tame and use beasts on any class | Fun. |

## Three things to keep in mind

1. **Compatibility with the Playerbots fork is not guaranteed per module.** Each one has
   to be tested on this exact setup. When one misbehaves, it goes in
   [TROUBLESHOOTING.md](TROUBLESHOOTING.md) like everything else.
2. **`autobalance` vs `solocraft` is an either/or**, and both interact oddly with a bot
   party that already forms a real group. Pick one, or neither, and tune it.
3. **Add a few at a time and test.** A realm that broke after adding six modules at once
   tells you nothing about which one did it.

## Status

Planned. Modules get real, tested instructions here as we add them, starting with
`mod-ah-bot` once the base realm is confirmed working.
