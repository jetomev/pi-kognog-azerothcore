# <img src="assets/icons/the-guide.png" class="nk-title-icon" alt=""> Optional — Adding modules

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
   cd /mnt/nvme/azerothcore-wotlk/modules
   git clone <module-repo-url>
   ```
   It must land at `/mnt/nvme/azerothcore-wotlk/modules/mod-<name>`.

2. **Reconfigure with the exact same cmake flags as Chapter 05.** Run from the existing
   `build` folder; everything already compiled stays cached, so only the new module
   compiles and `worldserver` relinks — minutes, not the original hours:
   ```
   cd /mnt/nvme/azerothcore-wotlk/build
   cmake .. \
       -DCMAKE_INSTALL_PREFIX=/mnt/nvme/azerothcore-wotlk/env/dist \
       -DCMAKE_C_COMPILER=/usr/bin/clang \
       -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
       -DWITH_WARNINGS=0 \
       -DTOOLS_BUILD=none \
       -DSCRIPTS=static \
       -DMODULES=static \
       -DCMAKE_BUILD_TYPE=Release
   ```

   > ⚠️ An earlier draft of this page suggested `-DAPPS_BUILD=none` here. **Don't** —
   > that skips rebuilding `worldserver` itself, which is exactly the binary the module
   > must be linked into. Chapter 05's flags (above) are the truth; the cmake summary
   > must say `Build applications : Yes (all)`.

   **Checkpoint:** before building, find the `Modules configuration (static)` list in
   the cmake output and confirm your new module's name appears in it. cmake also prints
   a `Modules config list` naming each module's config file — note it; some modules
   (e.g. `mod-junk-to-gold`) ship none and are simply always-on.

3. **Compile.** The realm can keep running during this — you're building a new binary
   next to the live one:
   ```
   make -j4
   ```
   Expect `[100%] Built target worldserver` at the end.

4. **The swap window** — stop, install, activate configs, start. This is the only part
   that takes the realm down, and it's a couple of minutes:
   ```
   sudo systemctl stop azerothcore-worldserver
   cd /mnt/nvme/azerothcore-wotlk/build && make install
   cd /mnt/nvme/azerothcore-wotlk/env/dist/etc/modules
   cp --update=none <name>.conf.dist <name>.conf
   sudo systemctl start azerothcore-worldserver
   ```
   Modules read `<name>.conf`, not `.conf.dist` — the `.dist` is the template, same
   convention as `worldserver.conf` in Chapter 06. (`--update=none` = "don't overwrite
   an existing .conf"; plain `cp -n` works too but prints a deprecation warning on
   Ubuntu 24.04's coreutils.)

5. **Database:** most modules bring their own SQL. AzerothCore's updater applies it
   automatically during that first start — no manual import needed (the updater is
   covered in Chapter 07). Watch it happen:
   ```
   sudo journalctl -u azerothcore-worldserver --since -10min --no-pager | grep -iE "error|updat|world init"
   ```
   You want to see the module's update applying, `World Initialized`, and **no** ERROR
   lines. If `systemctl start` seemed to do nothing, check
   `systemctl status azerothcore-worldserver` — a paste that misses its Enter key
   produces a very convincing silence.

Each module added below gets its exact repo, config, and any gotchas documented *as we
add it and test it* — not before.

## ✅ Installed on this realm — Wave 1, Batch A (2026-08-01)

Six modules, chosen from the [full ecosystem census](#the-census) below, installed
together in one build using the pattern above and verified live. All six are server-side
only — nothing to install on any player's client — and none conflict with each other or
with Playerbots.

| Module | What it does / why we added it |
|---|---|
| [`mod-learn-spells`](https://github.com/azerothcore/mod-learn-spells) | Auto-learns class spells on level-up. Kills the "back to the trainer every 2 levels" chore — the #1 friction for casual family leveling. **Verified:** new spells appear on level-up, no trainer visit. |
| [`mod-solo-lfg`](https://github.com/azerothcore/mod-solo-lfg) | Lets a solo player use the Dungeon Finder. **Verified:** solo queue accepted where the stock client refuses. |
| [`mod-duel-reset`](https://github.com/azerothcore/mod-duel-reset) | Resets cooldowns/HP/mana around duels — fair, endless family duels. |
| [`mod-junk-to-gold`](https://github.com/noisiver/mod-junk-to-gold) | Gray junk converts to coin on loot. No config file — always on once built. **Verified:** vendor trash arrives as money. |
| [`mod-player-bot-level-brackets`](https://github.com/DustinHendrickson/mod-player-bot-level-brackets) | Keeps the random-bot population spread across level ranges instead of drifting to 80 — the world stays alive at every level. Applied its own SQL on first boot (`bot_level_brackets_guild_tracker`). Effect is observed over days, not minutes. |
| [`mod-rndbot-sync`](https://github.com/Yuof/mod-rndbot-sync) | Caps bot max level at the highest *real* player online — the bot world grows **with** the family instead of ahead of it. Also observational. |

Install notes from the live run:

- All six cloned, then **one** cmake + `make -j4` (≈15 min on the Pi 5, zero errors) —
  batching the clones is fine; the "one at a time" rule is about *testing*, and these
  six are config-gated and independent.
- cmake's module list showed all seven (the six + `mod-playerbots`) before we built.
- First start: character DB applied the brackets module's update, then
  `World Initialized In 0 Minutes 24 Seconds`, no errors.
- Configs were activated with defaults; tuning (bracket percentages, sync behavior)
  comes after observing the realm for a few days.

## The census

In August 2026 we surveyed the **entire** ecosystem for this realm: all 112 official
`mod-*` repos, 403 community repos (top ~85 kept), and ~58 client addons/patches — each
rated for a Playerbots family realm on a Pi. The full table lives in the repo at
[`research/module-census-2026.md`](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/research/module-census-2026.md).
Its headline rules, which govern everything below:

- **Pin module commits to the fork's era.** The Playerbots fork lags upstream
  AzerothCore, so a module tracking bleeding-edge core APIs may not compile. If a build
  fails, check out an older module commit contemporaneous with the fork.
- **Only ONE of each:** one AH bot, one difficulty scaler (or none — the bot party *is*
  the scaling), one progression mod, one AoE-loot, one global chat.
- Never `mod-multi-client-check` — it blocks a family behind one NAT.
- The official org's `mod-playerbots` is a dead 2021 placeholder; the real project now
  lives in the [`mod-playerbots` org](https://github.com/mod-playerbots/mod-playerbots).

## Candidate modules for a solo + Playerbots realm

Curated shortlist (see the census for the rest). **Every repo below was verified live in
July 2026** — but repos move, so still check before you clone.

### Tier 1 — genuinely improves solo play

| Module | What it does | Notes |
|---|---|---|
| [`mod-ah-bot-plus`](https://github.com/NathanHandley/mod-ah-bot-plus) | Populates the auction house with buyable/sellable items | The reason to bother, on a low-pop realm. **Next up (Batch B).** Supersedes the org's [`mod-ah-bot`](https://github.com/azerothcore/mod-ah-bot): actively maintained, multi-character, and explicitly documents Playerbots coexistence (use a regular non-bot character as the AH character). Needs core ≥ commit `3f46e05` — verify the fork has it. |
| [`mod-autobalance`](https://github.com/azerothcore/mod-autobalance) | Scales dungeon/raid difficulty to your actual party size | Powerful but cuts both ways with bots — a full bot party reads as a group, so combined with Playerbots it can double-compensate. Needs tuning. |
| [`mod-aoe-loot`](https://github.com/azerothcore/mod-aoe-loot) | Loot every nearby corpse in one action | Big quality-of-life when grinding solo. |
| [`mod-learn-spells`](https://github.com/azerothcore/mod-learn-spells) | Auto-learns class spells on level-up | ✅ **Installed** (Wave 1 Batch A, above). |

### Tier 2 — quality of life

| Module | What it does | Notes |
|---|---|---|
| [`mod-transmog`](https://github.com/azerothcore/mod-transmog) | Change gear appearance (transmogrification) | Most popular AC module. Pure cosmetics. Actively maintained. |
| [`mod-npc-buffer`](https://github.com/azerothcore/mod-npc-buffer) | An NPC that buffs you on demand | Convenience. |
| [`mod-solocraft`](https://github.com/azerothcore/mod-solocraft) | Stat-scales you to handle group content solo | **Alternative** to autobalance — don't run both. May be redundant with a bot party. |
| [`mod-dynamic-xp`](https://github.com/azerothcore/mod-dynamic-xp) | Control leveling speed | Blizzlike, faster, or per-account. |

### Tier 3 — situational / thematic

| Module | What it does | Notes |
|---|---|---|
| [`mod-solo-lfg`](https://github.com/azerothcore/mod-solo-lfg) | Queue the dungeon finder without a full player group | ✅ **Installed** (Wave 1 Batch A, above). |
| [`mod-progression-system`](https://github.com/azerothcore/mod-progression-system) | ChromieCraft-style phased content unlocking (server-wide) | Matches this guide's client origin, but deliberately restricts progression. Advanced taste. |
| [`mod-npc-beastmaster`](https://github.com/azerothcore/mod-npc-beastmaster) | Tame and use beasts on any class | Fun. |

### Notable additions (verified July 2026)

Worth knowing about, from outside the original shortlist:

| Module | What it does | Notes |
|---|---|---|
| [`mod-individual-progression`](https://github.com/ZhengPeiRu21/mod-individual-progression) | **Per-character** Vanilla→TBC→WotLK progression | Not under the azerothcore org (ZhengPeiRu21's repo); very active, widely run *with* Playerbots, and has config hooks for autobalance/transmog/ah-bot. An excellent solo-campaign pick. Pairs with the AtlasLoot build on the [client add-ons](optional-client-addons.md) page. |
| [`mod-player-bot-level-brackets`](https://github.com/DustinHendrickson/mod-player-bot-level-brackets) | Controls the random-bot **level distribution** | ✅ **Installed** (Wave 1 Batch A, above) together with its sibling [`mod-rndbot-sync`](https://github.com/Yuof/mod-rndbot-sync). |
| [`mod-ale`](https://github.com/azerothcore/mod-ale) | Lua scripting engine (AzerothCore Lua Engine) | **Renamed** — `mod-eluna` now redirects here; use the new name. For writing your own scripted content. |
| [`mod-arac`](https://github.com/heyitsbench/mod-arac) | All races, all classes | Lives at `heyitsbench/mod-arac` (not the org); needs a client-side patch, so it's a bigger commitment. |

## Three things to keep in mind

1. **Compatibility with the Playerbots fork is not guaranteed per module.** Each one has
   to be tested on this exact setup. When one misbehaves, it goes in
   [TROUBLESHOOTING.md](TROUBLESHOOTING.md) like everything else.
2. **`autobalance` vs `solocraft` is an either/or**, and both interact oddly with a bot
   party that already forms a real group. Pick one, or neither, and tune it.
3. **Add a few at a time and test.** A realm that broke after adding six modules at once
   tells you nothing about which one did it.

## Status

**Wave 1 Batch A (6 modules) installed and verified live 2026-08-01** — see the
Installed section above for the tested procedure. Next: **Batch B, `mod-ah-bot-plus`**
(the auction house), then the wave 2 candidates from the census. For the **client-side**
half of this story — bot control panels, quest helpers, DBM — see
[Client add-ons](optional-client-addons.md).
