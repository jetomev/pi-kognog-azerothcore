# AzerothCore Module & Mod Census — 2026-08-01

Full sweep of the AzerothCore modding ecosystem for the `tpgaming01` family realm
(**Playerbots fork** on Pi 5 ARM64, Ubuntu 24.04, ~40 tuned bots, family-casual).
Three sections: **A. Official modules** (azerothcore org, 112 repos), **B. Community
modules** (~85 relevant of 403 found), **C. Client-side** (addons + patches, ~58).

**Ratings are for OUR realm**, not in the abstract: ★5 = must-have here, ★4 = strong
candidate, ★3 = fine/niche, ★2 = stale/redundant/misfit for us, ★1 = dead/avoid.
"Maintained" = active or recently pushed (frozen-but-works noted in comments).
Server modules run on the Pi (Linux, ARM64-neutral — census found zero ARM blockers).
Client addons are OS-independent (work identically on Win11 and Wine).

## ⚡ Headline findings (read first)

1. **Playerbots moved orgs**: `liyunfan1223/*` → **`mod-playerbots` org** (module 905★,
   fork 367★). Our guide's clone URLs still redirect, but docs should track the new org.
2. **The #1 compatibility rule is version skew**, not module conflicts: the fork lags
   upstream AC, so pin module commits contemporaneous with the fork's merge point.
3. **mod-ah-bot-plus (NathanHandley) beats org mod-ah-bot** — actively maintained,
   multi-character, explicitly documents playerbots coexistence. Our "NEXT: mod-ah-bot"
   plan should upgrade to this.
4. **mod-individual-progression officially supports playerbots** — the marquee solo-realm
   combo (vanilla→TBC→WotLK per player). One caveat: `AiPlayerbot.ApplyInstanceStrategies=0`
   for its custom Naxx40, plus 2 config flags.
5. **Only ONE of each**: one AH bot · one difficulty scaler (autobalance vs solocraft vs
   dungeon-scale — and with a bot party, arguably none) · one progression mod · one
   AoE-loot · one global chat.
6. **mod-eluna is now mod-ale**, and Lua scripting periodically breaks compiling on the
   playerbots fork — treat Eluna-dependent modules as higher-maintenance.
7. **LLM bot modules exist** (bots chatting via Ollama/OpenAI-API). Pi can't run inference —
   host Ollama on the desktop, point the module across the LAN. Fun, experimental.
8. Modules needing **client-side patches** (ARAC, worgoblin, custom BGs, Black Market AH)
   add per-player distribution burden — every family client needs patched files. Bots
   don't queue custom BGs at all.

## 🎯 Auren's proposed first waves (for discussion)

**Server wave 1 (safe, high value, low risk):**
mod-ah-bot-plus · mod-learn-spells · mod-solo-lfg · mod-duel-reset ·
mod-junk-to-gold · mod-player-bot-level-brackets · mod-rndbot-sync

**Server wave 2 (bigger personality changes, decide together):**
mod-transmog (+known junk-to-gold combo crash-fix PR — verify merged) · mod-aoe-loot ·
mod-dungeon-clear · mod-account-achievements · mod-account-mounts · mod-weekend-xp ·
mod-individual-progression (the big one — changes the whole realm's shape) ·
mod-ollama-chat (the fun one)

**Client starter kit (per family member):**
UnBot (not PlayerbotsPanel — census correction 2026-08-02) · pfQuest · AtlasLoot + Atlas · DBM-Warmane · Skada · GTFO ·
Bagnon · Postal · Altoholic · TurnIn · DalaranAH · LAA 4GB flag (before any HD pack)

---

## A. Official AzerothCore modules (github.com/azerothcore — 112 repos)

| Name | Type | For | Maintained | Incompatible with | Rec. | ★ | General Comments | OS | Link |
|---|---|---|---|---|---|---|---|---|---|
| mod-transmog | module | server | yes | (junk-to-gold crash combo now moot — that module removed from realm 2026-08-02) | yes | 4 | 178★ top module; appearance NPC, pure fun for family | Linux | https://github.com/azerothcore/mod-transmog |
| mod-ale | module | server | yes | version skew vs playerbots fork (hook mismatch) | no (for now) | 3 | Lua engine (ex mod-eluna, renamed 2026); only needed if we adopt Lua scripts; periodically breaks on the fork | Linux | https://github.com/azerothcore/mod-ale |
| mod-autobalance | module | server | yes | mod-solocraft, mod-dungeon-scale, NPCBots | no | 3 | Scales instances to party size — but bots count as players, so with a full bot party it does little for us | Linux | https://github.com/azerothcore/mod-autobalance |
| mod-ah-bot | module | server | yes | other AH bots | no | 3 | The classic AH bot; superseded by mod-ah-bot-plus (Section B) — keep only as fallback | Linux | https://github.com/azerothcore/mod-ah-bot |
| mod-progression-system | module | server | yes | mod-individual-progression | no | 2 | ChromieCraft's realm-wide staged progression; heavy SQL, wrong shape for a family realm | Linux | https://github.com/azerothcore/mod-progression-system |
| mod-solocraft | module | server | yes | mod-autobalance (never together) | no | 2 | Solo-buffs players in instances; redundant with a bot party and stacks dangerously with it | Linux | https://github.com/azerothcore/mod-solocraft |
| mod-aoe-loot | module | server | yes | TerraByte fork of same (pick one) | yes | 4 | Loot-all-nearby QoL everyone loves; history of skinning/quest-item bugs — test on our realm before family rollout | Linux | https://github.com/azerothcore/mod-aoe-loot |
| mod-solo-lfg | module | server | yes (frozen-ish) | — | yes | 5 | Canonical playerbots companion: solo Dungeon Finder; zero known conflicts | Linux | https://github.com/azerothcore/mod-solo-lfg |
| mod-anticheat | module | server | yes | open compile error on recent core | no | 2 | Anticheat for public realms; our players are family — needless surface | Linux | https://github.com/azerothcore/mod-anticheat |
| mod-guildhouse | module | server | yes | — | maybe | 3 | Purchasable guild house; charming for a family guild; see also bot-populated variant (Section B) | Linux | https://github.com/azerothcore/mod-guildhouse |
| mod-learn-spells | module | server | yes (frozen) | — | yes | 5 | Auto-learn class spells on level-up — removes trainer-run busywork for the kids; pure QoL | Linux | https://github.com/azerothcore/mod-learn-spells |
| mod-npc-enchanter | module | server | yes | — | maybe | 3 | Enchants without hunting mats/enchanter alts; slightly cheaty, family-friendly | Linux | https://github.com/azerothcore/mod-npc-enchanter |
| mod-zone-difficulty | module | server | yes | (companion to progression-system) | no | 2 | Only makes sense with mod-progression-system | Linux | https://github.com/azerothcore/mod-zone-difficulty |
| mod-eluna-lua-engine | module | server | NO (archived) | — | no | 1 | Dead; replaced by mod-ale | Linux | https://github.com/azerothcore/mod-eluna-lua-engine |
| mod-random-enchants | module | server | yes | — | maybe | 3 | Diablo-style random suffixes on loot — fun chaos; changes item economy | Linux | https://github.com/azerothcore/mod-random-enchants |
| mod-npc-beastmaster | module | server | yes | — | maybe | 3 | Any class tames hunter pets; already in guide candidates; whimsical family fun | Linux | https://github.com/azerothcore/mod-npc-beastmaster |
| mod-npc-services | module | server | yes | — | maybe | 3 | One NPC: bank/mail/respec; convenience vs immersion tradeoff | Linux | https://github.com/azerothcore/mod-npc-services |
| mod-account-achievements | module | server | yes (frozen) | — | yes | 4 | Achievements shared across your alts — great for a 3-player realm with alt armies | Linux | https://github.com/azerothcore/mod-account-achievements |
| mod-premium | module | server | yes | — | no | 2 | VIP perks system — meaningless when everyone is family | Linux | https://github.com/azerothcore/mod-premium |
| mod-congrats-on-level | module | server | yes (frozen) | — | maybe | 3 | Milestone rewards; nice touch for the kids' leveling | Linux | https://github.com/azerothcore/mod-congrats-on-level |
| mod-individual-xp | module | server | yes | — | maybe | 3 | Per-player XP rate command — lets son level fast while Balih stays blizzlike; overlaps playerbots' own rate configs | Linux | https://github.com/azerothcore/mod-individual-xp |
| mod-1v1-arena | module | server | yes | — | no | 2 | 1v1 rated arena; PvP infra for a PvE family realm | Linux | https://github.com/azerothcore/mod-1v1-arena |
| mod-azerothshard | module | server | stale (2024) | assumes AzerothShard DB | no | 1 | Server-specific grab-bag | Linux | https://github.com/azerothcore/mod-azerothshard |
| mod-ptr-template | module | server | yes | — | no | 2 | Instant premade characters — testing tool, not gameplay | Linux | https://github.com/azerothcore/mod-ptr-template |
| mod-breaking-news-override | module | server | yes | — | maybe | 3 | Custom news panel at char select — could show family-realm announcements; cute branding touch | Linux | https://github.com/azerothcore/mod-breaking-news-override |
| mod-duel-reset | module | server | yes | — | yes | 4 | Duels reset CDs/HP — perfect for father-son duels outside Stormwind | Linux | https://github.com/azerothcore/mod-duel-reset |
| mod-pvp-titles | module | server | yes (frozen) | — | no | 2 | Classic PvP titles from honor kills; PvE realm | Linux | https://github.com/azerothcore/mod-pvp-titles |
| mod-reward-played-time | module | server | yes | — | no | 2 | Played-time rewards; retention mechanics don't apply to family | Linux | https://github.com/azerothcore/mod-reward-played-time |
| mod-npc-talent-template | module | server | yes | — | maybe | 3 | Applies talent/glyph/gear templates — could help the kids skip theorycrafting | Linux | https://github.com/azerothcore/mod-npc-talent-template |
| mod-npc-buffer | module | server | yes | — | maybe | 3 | Buff NPC; already in guide candidates; convenience call | Linux | https://github.com/azerothcore/mod-npc-buffer |
| mod-cfbg | module | server | yes | playerbots' own cross-faction BG logic | no | 2 | Cross-faction BGs; fork already has bot BG options — enable only one system | Linux | https://github.com/azerothcore/mod-cfbg |
| mod-account-mounts | module | server | yes (frozen) | — | yes | 4 | Account-wide mounts — alt-friendly QoL, zero downside on a family realm | Linux | https://github.com/azerothcore/mod-account-mounts |
| mod-skip-dk-starting-area | module | server | yes (frozen) | — | maybe | 3 | Skip DK intro on repeat characters | Linux | https://github.com/azerothcore/mod-skip-dk-starting-area |
| mod-gain-honor-guard | module | server | yes (frozen) | — | no | 2 | Honor from guards; PvP-flavored | Linux | https://github.com/azerothcore/mod-gain-honor-guard |
| mod-better-item-reloading | module | server | yes | — | no | 2 | Dev tool for live item editing | Linux | https://github.com/azerothcore/mod-better-item-reloading |
| mod-weekend-xp | module | server | yes | mod-weekendbonus (pick one) | yes | 4 | Bonus XP on weekends — exactly when the family plays together | Linux | https://github.com/azerothcore/mod-weekend-xp |
| mod-dynamic-xp | module | server | yes | — | maybe | 3 | XP rate by level bracket; already in guide candidates | Linux | https://github.com/azerothcore/mod-dynamic-xp |
| mod-server-auto-shutdown | module | server | yes | — | no | 2 | Scheduled restarts; our systemd + backup timers already own this space | Linux | https://github.com/azerothcore/mod-server-auto-shutdown |
| mod-character-tools | module | server | yes (frozen) | — | no | 2 | Clone/import/export characters; admin tool | Linux | https://github.com/azerothcore/mod-character-tools |
| mod-npc-free-professions | module | server | yes | — | maybe | 3 | Free professions + recipes; big shortcut, family call | Linux | https://github.com/azerothcore/mod-npc-free-professions |
| mod-world-chat | module | server | yes | mod-global-chat, Gozzim/mod-globalchat | maybe | 3 | /world channel — with 3 humans spread across zones + bots, could be the family channel | Linux | https://github.com/azerothcore/mod-world-chat |
| mod-weapon-visual | module | server | yes | — | maybe | 3 | Weapon glow visuals on demand; cosmetic fun | Linux | https://github.com/azerothcore/mod-weapon-visual |
| mod-rdf-expansion | module | server | yes (frozen) | — | maybe | 3 | Queue older-expansion dungeons at level; pairs with solo-lfg | Linux | https://github.com/azerothcore/mod-rdf-expansion |
| mod-starter-guild | module | server | yes | — | maybe | 3 | Auto-join family guild at character creation — nice with a "Kognog" family guild | Linux | https://github.com/azerothcore/mod-starter-guild |
| mod-custom-login | module | server | yes (frozen) | — | no | 2 | Login announcements/rewards | Linux | https://github.com/azerothcore/mod-custom-login |
| mod-npc-gambler | module | server | yes | — | no | 2 | Gambling NPC; not for the kids | Linux | https://github.com/azerothcore/mod-npc-gambler |
| mod-reward-shop | module | server | yes | — | no | 2 | Token shop NPC; monetization-shaped | Linux | https://github.com/azerothcore/mod-reward-shop |
| mod-playerbots (org) | module | server | NO (dead 2021) | — | no | 1 | Placeholder only — the real module lives in the mod-playerbots org (Section B); never clone this one | Linux | https://github.com/azerothcore/mod-playerbots |
| mod-money-for-kills | module | server | yes | — | no | 2 | Cash per kill; inflation on a bot economy | Linux | https://github.com/azerothcore/mod-money-for-kills |
| mod-instance-reset | module | server | yes | — | maybe | 3 | Reset instances via NPC — handy for farm nights | Linux | https://github.com/azerothcore/mod-instance-reset |
| mod-morphsummon | module | server | yes | — | no | 2 | Morph pets/minions; cosmetic niche | Linux | https://github.com/azerothcore/mod-morphsummon |
| mod-guild-zone-system | module | server | yes | — | no | 2 | Guild-claimable zones; multi-guild feature | Linux | https://github.com/azerothcore/mod-guild-zone-system |
| mod-ip-tracker | module | server | yes (frozen) | — | no | 2 | Login IP tracking; public-realm admin | Linux | https://github.com/azerothcore/mod-ip-tracker |
| mod-racial-trait-swap | module | server | yes | — | no | 2 | Swap racials; min-max tool | Linux | https://github.com/azerothcore/mod-racial-trait-swap |
| mod-boss-announcer | module | server | yes | — | maybe | 3 | Server-wide boss-kill announcements — fun family bragging rights | Linux | https://github.com/azerothcore/mod-boss-announcer |
| mod-npc-all-mounts | module | server | yes | — | no | 2 | All mounts from an NPC; kills mount-collecting joy | Linux | https://github.com/azerothcore/mod-npc-all-mounts |
| mod-fireworks-on-level | module | server | yes (frozen) | — | maybe | 3 | Fireworks on level-up — the kids will love it; harmless | Linux | https://github.com/azerothcore/mod-fireworks-on-level |
| mod-multi-client-check | module | server | yes (frozen) | breaks shared-NAT households | no | 1 | Blocks multi-client per IP — would block OUR family behind one NAT; never install | Linux | https://github.com/azerothcore/mod-multi-client-check |
| mod-who-logged | module | server | yes | — | no | 2 | Console login prints; we disabled the console | Linux | https://github.com/azerothcore/mod-who-logged |
| mod-item-level-up | module | server | yes | — | no | 2 | Level-granting item | Linux | https://github.com/azerothcore/mod-item-level-up |
| mod-emblem-transfer | module | server | yes | — | maybe | 3 | Move emblems between alts; endgame QoL | Linux | https://github.com/azerothcore/mod-emblem-transfer |
| mod-arena-3v3-solo-queue | module | server | yes (WIP) | — | no | 2 | In development; PvP | Linux | https://github.com/azerothcore/mod-arena-3v3-solo-queue |
| mod-pvpscript | module | server | yes (frozen) | — | no | 2 | PvP kill scripts | Linux | https://github.com/azerothcore/mod-pvpscript |
| mod-pocket-portal | module | server | yes | — | maybe | 3 | Personal portal item; convenience | Linux | https://github.com/azerothcore/mod-pocket-portal |
| mod-queue-list-cache | module | server | yes | — | no | 2 | BG queue CPU optimization for big realms | Linux | https://github.com/azerothcore/mod-queue-list-cache |
| mod-npc-titles-tokens | module | server | yes | — | no | 2 | Titles for tokens | Linux | https://github.com/azerothcore/mod-npc-titles-tokens |
| mod-bg-reward | module | server | yes (frozen) | — | no | 2 | BG rewards | Linux | https://github.com/azerothcore/mod-bg-reward |
| mod-chat-login | module | server | yes (frozen) | — | no | 2 | Auto-join channel on login | Linux | https://github.com/azerothcore/mod-chat-login |
| mod-tic-tac-toe | module | server | yes | — | maybe | 3 | In-game tic-tac-toe — silly family fun, zero risk | Linux | https://github.com/azerothcore/mod-tic-tac-toe |
| mod-costumes | module | server | yes (frozen) | — | maybe | 3 | Costume morph items; kids | Linux | https://github.com/azerothcore/mod-costumes |
| mod-arena-replay | module | server | yes | — | no | 2 | Arena replays; PvP | Linux | https://github.com/azerothcore/mod-arena-replay |
| mod-npc-codebox | module | server | yes | — | no | 2 | Promo codes | Linux | https://github.com/azerothcore/mod-npc-codebox |
| mod-chat-transmitter | module | server | yes | — | maybe | 3 | WebSocket bridge for chat/commands — future HomeLab/Discord integration hook | Linux | https://github.com/azerothcore/mod-chat-transmitter |
| mod-pvp-zones | module | server | yes | — | no | 2 | World-PvP zones | Linux | https://github.com/azerothcore/mod-pvp-zones |
| mod-low-level-rbg | module | server | yes | — | no | 2 | Low-level random BGs | Linux | https://github.com/azerothcore/mod-low-level-rbg |
| mod-war-effort | module | server | yes | — | no | 2 | AQ war effort event | Linux | https://github.com/azerothcore/mod-war-effort |
| mod-phased-duels | module | server | yes | — | maybe | 3 | Duels in own phase — pairs with duel-reset | Linux | https://github.com/azerothcore/mod-phased-duels |
| mod-buff-command | module | server | yes (frozen) | — | maybe | 3 | .buff self-buff; simpler than a buffer NPC | Linux | https://github.com/azerothcore/mod-buff-command |
| mod-global-chat | module | server | yes | mod-world-chat (pick one) | no | 2 | Alternative global chat | Linux | https://github.com/azerothcore/mod-global-chat |
| mod-bg-item-reward | module | server | yes (frozen) | — | no | 2 | BG item rewards | Linux | https://github.com/azerothcore/mod-bg-item-reward |
| mod-mall-teleport | module | server | yes (frozen) | — | no | 2 | Mall teleport | Linux | https://github.com/azerothcore/mod-mall-teleport |
| mod-spell-regulator | module | server | yes | — | no | 2 | Spell coefficient tuning; balance surgery we don't need | Linux | https://github.com/azerothcore/mod-spell-regulator |
| mod-quick-teleport | module | server | yes (frozen) | — | no | 2 | Teleport commands | Linux | https://github.com/azerothcore/mod-quick-teleport |
| mod-top-arena | module | server | yes | — | no | 2 | Arena stats | Linux | https://github.com/azerothcore/mod-top-arena |
| mod-antifarming | module | server | yes (frozen) | — | no | 2 | Anti honor-farming | Linux | https://github.com/azerothcore/mod-antifarming |
| mod-premium-lib | module | server | stale (2022) | — | no | 1 | Dependency lib for premium mods | Linux | https://github.com/azerothcore/mod-premium-lib |
| mod-pvpstats-announcer | module | server | yes (frozen) | — | no | 2 | Killstreak announcements | Linux | https://github.com/azerothcore/mod-pvpstats-announcer |
| mod-desertion-warnings | module | server | yes (frozen) | — | no | 2 | RDF deserter penalties | Linux | https://github.com/azerothcore/mod-desertion-warnings |
| mod-low-level-arena | module | server | yes (frozen) | — | no | 2 | Low-level arena | Linux | https://github.com/azerothcore/mod-low-level-arena |
| mod-instanced-worldbosses | module | server | yes | — | maybe | 3 | World bosses phased per group — family can kill world bosses without contention (bots don't contest anyway) | Linux | https://github.com/azerothcore/mod-instanced-worldbosses |
| mod-auto-revive | module | server | yes (frozen) | — | no | 2 | Auto-revive zones | Linux | https://github.com/azerothcore/mod-auto-revive |
| mod-detailed-logging | module | server | yes (frozen) | — | no | 2 | Verbose logging; Pi journal noise | Linux | https://github.com/azerothcore/mod-detailed-logging |
| mod-alpha-rewards | module | server | NO (archived) | — | no | 1 | Abandoned | Linux | https://github.com/azerothcore/mod-alpha-rewards |
| mod-morph-all-players | module | server | yes (frozen) | — | no | 2 | Mass-morph gimmick | Linux | https://github.com/azerothcore/mod-morph-all-players |
| mod-dmf-switch | module | server | yes (frozen) | — | no | 2 | Move Darkmoon Faire | Linux | https://github.com/azerothcore/mod-dmf-switch |
| mod-system-vip | module | server | yes | — | no | 2 | VIP levels | Linux | https://github.com/azerothcore/mod-system-vip |
| mod-keep-out | module | server | yes | — | no | 2 | Zone blocking | Linux | https://github.com/azerothcore/mod-keep-out |
| mod-npc-morph | module | server | yes | — | no | 2 | Morph NPC | Linux | https://github.com/azerothcore/mod-npc-morph |
| mod-promotion-azerothcore | module | server | yes | — | no | 2 | New-player boost promo | Linux | https://github.com/azerothcore/mod-promotion-azerothcore |
| mod-chromie-xp | module | server | yes (frozen) | — | no | 2 | ChromieCraft XP-stop | Linux | https://github.com/azerothcore/mod-chromie-xp |
| mod-cta-switch | module | server | yes (frozen) | — | no | 2 | Call-to-Arms swap | Linux | https://github.com/azerothcore/mod-cta-switch |
| mod-bg-auto-queue | module | server | yes | — | no | 2 | BG auto-requeue | Linux | https://github.com/azerothcore/mod-bg-auto-queue |
| mod-learn-highest-talent | module | server | yes (frozen) | — | no | 2 | Auto max talent ranks | Linux | https://github.com/azerothcore/mod-learn-highest-talent |
| mod-ip2nation | module | server | NO (archived) | — | no | 1 | Geo tables; dead | Linux | https://github.com/azerothcore/mod-ip2nation |
| mod-pvp-quests | module | server | yes | — | no | 2 | PvP quests | Linux | https://github.com/azerothcore/mod-pvp-quests |
| mod-acore-subscriptions | module | server | yes | requires acore-cms | no | 1 | CMS integration | Linux | https://github.com/azerothcore/mod-acore-subscriptions |
| mod-dress-npc | module | server | yes | — | maybe | 3 | Dressing-room preview NPC; pairs with transmog | Linux | https://github.com/azerothcore/mod-dress-npc |
| mod-notify-muted | module | server | yes | — | no | 2 | Mute notifications | Linux | https://github.com/azerothcore/mod-notify-muted |
| mod-quest-status | module | server | yes (frozen) | — | no | 2 | Quest ID lookup | Linux | https://github.com/azerothcore/mod-quest-status |
| mod-arenaspectator | module | server | NO (archived) | — | no | 1 | Dead | Linux | https://github.com/azerothcore/mod-arenaspectator |
| mod-resurrection-scroll | module | server | yes | — | no | 2 | Res scroll item | Linux | https://github.com/azerothcore/mod-resurrection-scroll |
| mod-quest-helper | module | server | yes (WIP) | — | no | 2 | Early WIP | Linux | https://github.com/azerothcore/mod-quest-helper |

## B. Community / third-party modules (outside the org — top ~85 of 403 found)

| Name | Type | For | Maintained | Incompatible with | Rec. | ★ | General Comments | OS | Link |
|---|---|---|---|---|---|---|---|---|---|
| mod-playerbots/mod-playerbots | module | server | yes | requires the matching custom fork | **INSTALLED ✔** | 5 | THE module (905★) — our realm's beating heart; note the org move from liyunfan1223 | Linux | https://github.com/mod-playerbots/mod-playerbots |
| mod-playerbots/azerothcore-wotlk | module (core fork) | server | yes | lags upstream AC — pin module revs to it | **INSTALLED ✔** | 5 | The custom core (367★) our realm runs; same lineage as the guide's clone | Linux | https://github.com/mod-playerbots/azerothcore-wotlk |
| ZhengPeiRu21/mod-individual-progression | module | server | yes | noisiver/mod-progression, wrath-of-the-vanilla, org progression-system; Naxx40 needs ApplyInstanceStrategies=0 | yes (wave 2, big decision) | 5 | 248★ marquee solo-realm module: each player progresses vanilla→TBC→WotLK with era-true tuning; officially playerbots-compatible; needs EnablePlayerSettings=1 + DBC.EnforceItemAttributes=0; would reshape the whole realm — family decision | Linux | https://github.com/ZhengPeiRu21/mod-individual-progression |
| ZhengPeiRu21/mod-playerbots | module | server | dormant (2024-06) | — | no | 2 | Her IP-compat bot fork; superseded — modern IP works on the main fork | Linux | https://github.com/ZhengPeiRu21/mod-playerbots |
| DustinHendrickson/mod-ollama-chat | module | server | yes | needs Ollama endpoint (off-Pi) | yes (fun, wave 2) | 4 | 110★ — bots talk via local LLM with personalities; host Ollama on the desktop, point across LAN; the family will not stop laughing | Linux (+LAN LLM box) | https://github.com/DustinHendrickson/mod-ollama-chat |
| NathanHandley/mod-ah-bot-plus | module | server | yes | org mod-ah-bot, araxiaonline/mod-auctionator (only one AH bot) | yes (wave 1 — replaces our mod-ah-bot plan) | 5 | 109★ much-improved AH bot: config-driven, multi-character, GM commands, documented playerbots coexistence (use a regular non-bot char as the AH character); needs AC ≥ 3f46e05 — verify fork has it | Linux | https://github.com/NathanHandley/mod-ah-bot-plus |
| liyunfan1223/unbot-addon | mod (addon) | client | frozen-but-works | — | **yes — installed 2026-08-01** (PlayerbotsPanel was a census error: early-alpha, nonfunctional) | 4 | The fork's own control addon (94★); Chinese-first UI; superseded for us by PlayerbotsPanel | Win+Wine | https://github.com/liyunfan1223/unbot-addon |
| ZhengPeiRu21/mod-challenge-modes | module | server | yes | AnchyDev/HardMode (overlap) | maybe | 4 | 67★ hardcore/ironman/self-found toggles per character — great "second lap" content; proven in the big playerbots repack | Linux | https://github.com/ZhengPeiRu21/mod-challenge-modes |
| DustinHendrickson/mod-player-bot-level-brackets | module | server | yes | — | yes (wave 1) | 5 | 57★ keeps bot population spread across level brackets — directly fixes the "everyone's at 80, lowbie zones empty" drift on our ~40-bot realm | Linux | https://github.com/DustinHendrickson/mod-player-bot-level-brackets |
| heyitsbench/mod-arac | module | server | yes | berubejd/mod-uac (pick one); needs client patch on EVERY family client | no | 3 | 57★ all-races-all-classes; the client-patch distribution burden decides against it — see mod-uac for patch-free | Linux + client patch | https://github.com/heyitsbench/mod-arac |
| Hokken/mod-llm-chatter | module | server | yes | needs external LLM API | maybe | 3 | 55★ LLM bot chat via OpenAI-compatible APIs (alternative to ollama-chat; pick one) | Linux | https://github.com/Hokken/mod-llm-chatter |
| jrad7/mod-dungeon-clear | module | server | yes | — | yes (wave 2) | 4 | 49★ makes bots actually finish dungeons (pathing/objectives) — directly improves our bot-party experience | Linux | https://github.com/jrad7/mod-dungeon-clear |
| InstanceForge/mod-dungeon-master | module | server | yes | — | no | 3 | 45★ randomly generated dungeons; intriguing but experimental; bots unknown | Linux | https://github.com/InstanceForge/mod-dungeon-master |
| DustinHendrickson/mod-ollama-bot-buddy | module | server | yes | needs Ollama | no (experimental) | 3 | 43★ LLM-driven bot control; younger than ollama-chat | Linux | https://github.com/DustinHendrickson/mod-ollama-bot-buddy |
| deseven/mod-playerbots-characters | module | server | yes | needs external LLM | no (experimental) | 3 | 37★ persistent LLM personalities for bots | Linux | https://github.com/deseven/mod-playerbots-characters |
| ZhengPeiRu21/mod-reagent-bank | module | server | yes | Day36512 account-wide variant (pick one) | maybe | 4 | 36★ retail-style reagent bank; proven in the playerbots repack; crafting-family QoL | Linux | https://github.com/ZhengPeiRu21/mod-reagent-bank |
| Helias/mod-bg-slaveryvalley | module | server | stale (2024) | needs client map patch; bots don't queue custom BGs | no | 2 | Custom BG — no value on a bots realm | Linux + patch | https://github.com/Helias/mod-bg-slaveryvalley |
| heyitsbench/mod-worgoblin | module | server | yes | needs core patches + client patch | no | 2 | 34★ playable Worgen/Goblin; core-patch-on-patched-fork risk + client distribution — too invasive | Linux + patch | https://github.com/heyitsbench/mod-worgoblin |
| gitdalisar/mod-Faction-Free | module | server | yes | org mod-cfbg, AllowTwoSide configs | maybe | 3 | 34★ cross-faction everything — would let family mix Horde/Alliance! Bots-cross-faction untested; worth a cautious trial if factions split the family | Linux | https://github.com/gitdalisar/mod-Faction-Free |
| noisiver/mod-assistant | module | server | yes | — | maybe | 3 | 34★ all-in-one assistant NPC (heirlooms/glyphs/gems); widely used | Linux | https://github.com/noisiver/mod-assistant |
| Youpeoples/Black-Market-Auction-House | module | server | yes | needs client patch | no | 3 | 31★ MoP Black Market backport; cool but client-patch burden | Linux + patch | https://github.com/Youpeoples/Black-Market-Auction-House |
| AnchyDev/StatBooster | module | server | NO (archived) | — | no | 2 | Random enchant loot; archived — org mod-random-enchants is the live alternative | Linux | https://github.com/AnchyDev/StatBooster |
| noisiver/mod-junk-to-gold | module | server | yes (frozen) | quest integrity (destroys gray quest items) | **NO — installed 2026-08-01, REMOVED 2026-08-02** | 2 | Destroys gray QUEST items & quest-starters on loot (its issue #7; fix PR #9 REJECTED by maintainer — "doesn't match my vision"). Always-on (no config) = rebuild to remove. Census rule earned: a loot-touching module must respect quests | Linux | https://github.com/noisiver/mod-junk-to-gold |
| silviu20092/mod-mythic-plus | module | server | yes | araxia mythic-plus, autobalance-family (pick one scaler) | no | 3 | 27★ M+ keystones for WotLK; interesting endgame, but scaling mods + bots = config science project | Linux | https://github.com/silviu20092/mod-mythic-plus |
| milestorme/mod-solo-lfg | module | server | stale (2023) | org mod-solo-lfg (pick one) | no | 2 | Older solo-LFG lineage; use the org one | Linux | https://github.com/milestorme/mod-solo-lfg |
| 55Honey/Acore_eventScripts | script pack | server | yes (frozen) | requires Eluna/mod-ale (fragile on fork) | no | 2 | Lua event scripts; Eluna dependency makes it high-maintenance on our fork | Linux | https://github.com/55Honey/Acore_eventScripts |
| silviu20092/mod-item-upgrade | module | server | yes | — | maybe | 3 | 25★ item ilvl-upgrade system; endgame gold sink | Linux | https://github.com/silviu20092/mod-item-upgrade |
| AnchyDev/DungeonRespawn | module | server | NO (archived) | hallgaeuer/mod-quick-respawn overlap | no | 2 | Archived; quick-respawn is the live one | Linux | https://github.com/AnchyDev/DungeonRespawn |
| dunjeon/mod-TimeIsTime | module | server | yes (frozen) | — | maybe | 3 | Day/night cycle speed control; atmospheric toy, proven in repack | Linux | https://github.com/dunjeon/mod-TimeIsTime |
| pangolp/mod-quest-loot-party | module | server | yes | noisiver/mod-groupquests overlap | **yes — INSTALLED 2026-08-02, field-verified** | 5 | THE bot-party fix: quest items are ALWAYS dealt group-loot-style to ONE member per corpse (bots eat ~4/5 of deals); this gives every member their own copy. Verified live: armbands for everyone w/ bots in party | Linux | https://github.com/pangolp/mod-quest-loot-party |
| AnchyDev/BreakingNewsOverride | module | server | NO (archived) | org mod-breaking-news-override | no | 2 | Archived; org variant lives | Linux | https://github.com/AnchyDev/BreakingNewsOverride |
| araxiaonline/mod-auctionator | module | server | yes | other AH bots | no | 3 | AH population fork; ah-bot-plus is the better-documented pick | Linux | https://github.com/araxiaonline/mod-auctionator |
| DustinHendrickson/mod-city-siege | module | server | yes | — | maybe | 4 | 20★ dynamic city sieges — the realm fights back; playerbots-native author; could be a family event night | Linux | https://github.com/DustinHendrickson/mod-city-siege |
| NathanHandley/mod-dungeon-scale | module | server | yes | org autobalance, solocraft (NEVER together) | no | 3 | AutoBalance fork; same "bots count as players" caveat | Linux | https://github.com/NathanHandley/mod-dungeon-scale |
| Youpeoples/Prestige-and-Draft-Mode | module | server | yes | — | no | 3 | Prestige leveling; second-lap content, niche | Linux | https://github.com/Youpeoples/Prestige-and-Draft-Mode |
| noisiver/mod-weekendbonus | module | server | yes (frozen) | org mod-weekend-xp (pick one) | no | 3 | Weekend bonuses (XP/money/rep); org weekend-xp simpler | Linux | https://github.com/noisiver/mod-weekendbonus |
| 55Honey/Acore_LevelUpReward | script | server | frozen | requires Eluna | no | 2 | Lua milestone rewards; Eluna dependency | Linux | https://github.com/55Honey/Acore_LevelUpReward |
| BytesGalore/mod-no-hearthstone-cooldown | module | server | yes (frozen) | — | maybe | 3 | No hearthstone CD; tiny hook, low risk, big family QoL | Linux | https://github.com/BytesGalore/mod-no-hearthstone-cooldown |
| Helias/mod-bg-twinpeaks | module | server | stale (2024) | client patch; bots don't queue custom BGs | no | 2 | Custom BG | Linux + patch | https://github.com/Helias/mod-bg-twinpeaks |
| silviu20092/mod-reforging | module | server | yes | — | maybe | 3 | 17★ Cata-style reforging; endgame tinkering | Linux | https://github.com/silviu20092/mod-reforging |
| araxiaonline/Delves | module | server | yes | tied to Araxia Eluna-TS stack | no | 2 | Solo Delves scenarios; stack dependency too heavy | Linux | https://github.com/araxiaonline/Delves |
| noisiver/mod-progression | module | server | yes | mod-individual-progression, wrath-of-the-vanilla (exactly one) | no | 3 | Realm-wide patch progression; IP is the better fit per-player | Linux | https://github.com/noisiver/mod-progression |
| TerraByte-tbwps/mod-aoe-loot | module | server | yes | org mod-aoe-loot (pick one) | maybe | 3 | AoE-loot rebuilt "without loot loss" — candidate replacement if org version's bugs bite us | Linux | https://github.com/TerraByte-tbwps/mod-aoe-loot |
| araxiaonline/mod-mythic-plus | module | server | yes | silviu mythic-plus, scalers | no | 3 | Araxia's M+ flavor | Linux | https://github.com/araxiaonline/mod-mythic-plus |
| Old-Man-Warcraft/mod-nemesis-system | module | server | yes | — | maybe | 3 | 15★ deaths spawn revenge "nemesis" mobs — spicy open-world flavor | Linux | https://github.com/Old-Man-Warcraft/mod-nemesis-system |
| sogladev/mod-vanilla-naxxramas | module | server | yes | IP's built-in Naxx40; expect bot instance-strategy crashes | no | 3 | Vanilla Naxx40 standalone; if we ever run IP we get Naxx40 there | Linux | https://github.com/sogladev/mod-vanilla-naxxramas |
| Gozzim/mod-globalchat | module | server | stale (2023) | world-chat variants | no | 2 | Another global chat | Linux | https://github.com/Gozzim/mod-globalchat |
| ZhengPeiRu21/mod-leech | module | server | yes | — | no | 3 | Leech-heal on damage; changes combat feel | Linux | https://github.com/ZhengPeiRu21/mod-leech |
| pangolp/mod-recruit-friend | module | server | yes | 55Honey RAF overlap | no | 2 | RAF system; family doesn't need recruitment incentives | Linux | https://github.com/pangolp/mod-recruit-friend |
| noisiver/mod-groupquests | module | server | NO (archived) | quest-loot-party overlap | no | 3 | Archived but the concept (shared quest drops) lives in quest-loot-party | Linux | https://github.com/noisiver/mod-groupquests |
| Gozzim/mod-npc-spectator | module | server | yes | — | no | 2 | Arena spectating NPC | Linux | https://github.com/Gozzim/mod-npc-spectator |
| silviu20092/mod-improved-bank | module | server | yes | — | maybe | 3 | Bigger bank; proven in repack; hoarder-family QoL | Linux | https://github.com/silviu20092/mod-improved-bank |
| Hokken/mod-llm-guide | module | server | yes | needs LLM | no | 2 | AI guide NPC; novelty | Linux | https://github.com/Hokken/mod-llm-guide |
| silviu20092/mod-flightmaster-whistle | module | server | yes | — | maybe | 3 | BfA flight whistle; travel QoL | Linux | https://github.com/silviu20092/mod-flightmaster-whistle |
| Hextv/wrath-of-the-vanilla-v2 | module | server | yes | progression mods (exactly one) | no | 2 | Vanilla-locked WotLK core; not our direction | Linux | https://github.com/Hextv/wrath-of-the-vanilla-v2 |
| Flerp/mod-autofish | module | server | yes | — | maybe | 3 | Auto-fishing — Balih's fishing chair upgrade; slightly cheaty, entirely pleasant | Linux | https://github.com/Flerp/mod-autofish |
| zyggy123/Treasure-Chest-System | module | server | yes | — | maybe | 3 | GM-placed treasure chests — dad hides treasure for the kids; delightful family tool | Linux | https://github.com/zyggy123/Treasure-Chest-System |
| AnchyDev/HardMode | module | server | NO (archived) | challenge-modes | no | 2 | Archived; challenge-modes lives | Linux | https://github.com/AnchyDev/HardMode |
| avarishd/mod-brawlers-guild | module | server | yes | — | maybe | 3 | MoP Brawler's Guild backport — solo arena fights, fun with family spectating | Linux | https://github.com/avarishd/mod-brawlers-guild |
| DustinHendrickson/mod-player-bot-reset | module | server | yes | — | no | 3 | Bots reset to 1 at cap (perpetual leveling world); conflicts with our "family levels up over months" arc | Linux | https://github.com/DustinHendrickson/mod-player-bot-reset |
| thanhtong89/mod-auto-gather | module | server | yes | — | no | 2 | Auto-gather nodes; too cheaty even for us | Linux | https://github.com/thanhtong89/mod-auto-gather |
| Tereneckla/mod-profession-experience | module | server | yes | — | maybe | 3 | XP from profession skill-ups — legitimizes crafting-day playstyles | Linux | https://github.com/Tereneckla/mod-profession-experience |
| forumcorex/mod-missing-objectives | module | server | yes | — | maybe | 3 | Restores missing dungeon quest objectives; quiet data-quality fix | Linux | https://github.com/forumcorex/mod-missing-objectives |
| noisiver/mod-appreciation | module | server | yes (frozen) | — | no | 2 | Level-boost service | Linux | https://github.com/noisiver/mod-appreciation |
| Day36512/mod-reagent-bank-account | module | server | yes | ZhengPeiRu21 reagent-bank (pick one) | maybe | 3 | Account-wide reagent bank + addon; the account-wide twist fits our alt-army style | Linux | https://github.com/Day36512/mod-reagent-bank-account |
| DustinHendrickson/mod-player-bot-guildhouse | module | server | yes | — | maybe | 3 | GM-Island guildhouse populated by living bots; pairs with org guildhouse ambitions | Linux | https://github.com/DustinHendrickson/mod-player-bot-guildhouse |
| privatecore/mod-python-engine | module | server | yes | Eluna alternative | no | 2 | Python scripting engine; young — but philosophically interesting for us later | Linux | https://github.com/privatecore/mod-python-engine |
| hallgaeuer/mod-quick-respawn | module | server | yes (frozen) | DungeonRespawn overlap | maybe | 3 | Instant ghost respawn near instances — removes the corpse-run for the kids | Linux | https://github.com/hallgaeuer/mod-quick-respawn |
| thanhtong89/mod-shared-professions | module | server | yes | — | maybe | 3 | Account-wide professions; big alt QoL, big shortcut — family call | Linux | https://github.com/thanhtong89/mod-shared-professions |
| justin-kaufmann/mod-changeablespawnrates | module | server | yes | — | no | 3 | Spawn-timer tuning; proven in repack; we have no spawn complaints | Linux | https://github.com/justin-kaufmann/mod-changeablespawnrates |
| kjack9/mod-dead-means-dead | module | server | stale (2023) | — | no | 3 | Cleared-stays-cleared respawns; immersive but stale | Linux | https://github.com/kjack9/mod-dead-means-dead |
| milestorme/mod-dynamic-xp | module | server | stale (2019) | org mod-dynamic-xp | no | 1 | Ancient; org version lives | Linux | https://github.com/milestorme/mod-dynamic-xp |
| sogladev/mod-reset-raid-cooldowns | module | server | yes | — | maybe | 3 | Reset CDs between raid pulls — casual-raid friendly | Linux | https://github.com/sogladev/mod-reset-raid-cooldowns |
| lightninjay/mod-tcg-vendors | module | server | yes | — | maybe | 3 | TCG/promo vendors — mount/toy collectors rejoice | Linux | https://github.com/lightninjay/mod-tcg-vendors |
| Zerkenn/mod-character-services | module | server | yes | — | maybe | 3 | Rename/customize/faction-change NPC — replaces GM SQL surgery for those requests | Linux | https://github.com/Zerkenn/mod-character-services |
| Exitare/mod-discord-webhook | module | server | yes | — | maybe | 3 | Server events → Discord; future family-Discord integration | Linux | https://github.com/Exitare/mod-discord-webhook |
| Yuof/mod-rndbot-sync | module | server | yes | — | yes (wave 1) | 4 | Syncs bot max level to highest online player — keeps the bot world growing WITH the family instead of ahead of it | Linux | https://github.com/Yuof/mod-rndbot-sync |
| BeardBear33/mod-guild-village | module | server | yes | — | maybe | 3 | Guild village, built/tested on the playerbots fork on Ubuntu — pedigree matches our stack exactly | Linux | https://github.com/BeardBear33/mod-guild-village |
| Zerathane/mod-token-turnin | module | server | yes | — | maybe | 3 | Auto tier-token redemption; playerbots-fork native | Linux | https://github.com/Zerathane/mod-token-turnin |
| barnaclebarry/mod-optimal-bot-raid | module | server | yes (very new) | — | no (watch) | 3 | Optimized raid orchestration for bots — watch this one mature | Linux | https://github.com/barnaclebarry/mod-optimal-bot-raid |
| AlsoNotMehh/AccountBound | module | server | yes | org account-achievements/mounts overlap | maybe | 3 | Account-wide everything in one module — could replace two org modules; younger code | Linux | https://github.com/AlsoNotMehh/AccountBound |
| berubejd/mod-uac | module | server | yes | mod-arac (pick one) | maybe | 3 | Any-race-any-class WITHOUT client patch — the ARAC alternative that respects our distribution constraints | Linux | https://github.com/berubejd/mod-uac |
| hallgaeuer/mod-dynamic-loot-rates | module | server | stale (2023) | — | no | 2 | Dynamic loot rates; proven in repack but stale | Linux | https://github.com/hallgaeuer/mod-dynamic-loot-rates |

## C. Client-side — addons & patches (3.3.5a build 12340)

All addons are plain Lua/XML in `Interface/AddOns` — **identical on Windows 11 and Wine**.
Only helper apps (updater, LAA flagger) are Windows programs. Patches are MPQ files in
`Data/` (OS-independent, reversible by deleting) except exe/DLL patchers (test on Wine).

| Name | Type | For | Maintained | Incompatible with | Rec. | ★ | General Comments | OS | Link |
|---|---|---|---|---|---|---|---|---|---|
| PlayerbotsPanel | mod (addon) | client | alpha | — | **no — CORRECTED 2026-08-02** | 1 | Census error, caught at install time: its own README says EARLY ALPHA / DOESN'T WORK and it requires a Broker + emulator companion stack. Nonfunctional as shipped; UnBot took its slot in the kit | Win+Wine | https://github.com/azcguy/PlayerbotsPanel |
| unbot-addon | mod (addon) | client | frozen-but-works | — | **yes — installed 2026-08-01** | 4 | Fork-author's own panel (UnBot + YssBossLoot); took PlayerbotsPanel's slot after that census error; `/ub` in game, works | Win+Wine | https://github.com/liyunfan1223/unbot-addon |
| TurnIn | mod (addon) | client | frozen-but-works | — | yes | 4 | Auto accept/turn-in quests — transformative when marching a bot party through quest hubs | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/TurnIn-2.1.zip |
| DalaranAH | mod (addon) | client | yes | — | yes | 4 | One-click AH-NPC access, built for AH-bot realms — pairs with mod-ah-bot-plus | Win+Wine | https://github.com/NoM0Re/DalaranAH/releases/latest/download/DalaranAH.zip |
| pfQuest (wotlk) | mod (addon) | client | yes | run ONE quest helper | yes | 5 | THE maintained quest helper (shagu, WotLK releases); NOT the "turtle" variant (1.12-only) | Win+Wine | https://github.com/shagu/pfQuest |
| Questie (335 branch) | mod (addon) | client | frozen-but-works | run ONE quest helper | no | 3 | Real Aldori15 3.3.5 fork; pfQuest is the maintained pick | Win+Wine | https://github.com/Aldori15/Questie/archive/refs/heads/335.zip |
| Zygor Guides Remaster | mod (addon) | client | yes | — | maybe | 4 | Step-by-step leveling guide with arrow — ideal for the son leveling solo at college | Win+Wine | https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK |
| Carbonite | mod (addon) | client | frozen | quest helpers overlap | no | 3 | All-in-one map/quest; heavy; pick pfQuest instead | Win+Wine | https://github.com/anzz1/Carbonite-3.3.5 |
| TomTom | mod (addon) | client | frozen-but-works | — | maybe | 3 | `/way` waypoint arrow; pairs with guides | Win+Wine | https://www.curseforge.com/wow/addons/tomtom/files/4090439 |
| GatherMate2 | mod (addon) | client | frozen-but-works | — | maybe | 3 | Node maps pre-seeded with Wowhead data; for the gatherers | Win+Wine | https://github.com/osdeibi/GatherMate2-WOW-Classic-WOTLK |
| AtlasLoot Enhanced | mod (addon) | client | frozen-but-works | — | yes | 4 | Browse boss loot in-game — "what do we want from this dungeon, kids?" | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/AtlasLoot.zip |
| Atlas | mod (addon) | client | frozen-but-works | — | yes | 4 | Dungeon maps with boss locations; AtlasLoot's companion | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Atlas.zip |
| DBM (DBM-Warmane) | mod (addon) | client | yes | — | yes | 5 | THE boss-mod, actively maintained (Zidras); works on AzerothCore despite the name | Win+Wine | https://github.com/Zidras/DBM-Warmane |
| GTFO | mod (addon) | client | frozen-but-works | — | yes | 4 | Yells when you stand in fire — built for teaching new family members | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/GTFO.zip |
| Skada | mod (addon) | client | yes | run ONE meter | yes | 4 | Light damage meter, actively maintained (bkader) — friendly family DPS rivalry | Win+Wine | https://github.com/bkader/Skada-WoTLK |
| Details! (backport) | mod (addon) | client | frozen-but-works | run ONE meter | no | 3 | Heavier meter; Skada wins on 32-bit client memory | Win+Wine | https://github.com/Bunny67/Details-WotLK |
| Recount | mod (addon) | client | no | meters | no | 2 | Superseded | Win+Wine | https://felbite.com/wow-3-3-5-addons/ |
| WeakAuras (backport) | mod (addon) | client | yes | — | maybe | 4 | Modern WA on 3.3.5 — power-user tool, overkill for the kids | Win+Wine | https://github.com/NoM0Re/WeakAuras-WotLK |
| AI VoiceOver + sound packs | mod (addon) | client | yes | — | **wave-2 headline** | 5 | AI-voiced quest-givers/gossip (race+gender-matched); **census gap found by Balih 2026-08-04**. Ships a 3.3.5 build + a WotLK backport (s0h2x); data packs now cover Vanilla+TBC+WotLK (multi-GB — HD-pack LAN-copy strategy applies); known quirk: 3.3.5a client lacks StopSound (lines can't always be cut mid-play). Research session to pick addon build + pack combo, then trial-and-bless | Win+Wine | https://github.com/mrthinger/wow-voiceover + https://github.com/s0h2x/AI_VoiceOver-WotLK |
| Immersion (WotLK backport) | mod (addon) | client | yes | — | **wave-2 headline** | 5 | Cinematic quest/gossip dialog (animated NPC portrait speaking, story-first pacing) replacing the default text wall; **VoiceOver's natural partner — same porter (s0h2x) as AI_VoiceOver-WotLK, install as a pair**. Balih-picked 2026-08-04. Alternatives ruled out: fxpw fork (derivative), Aireeh (Ascension-specific) | Win+Wine | https://github.com/s0h2x/Immersion-WotLK |
| Method Raid Tools | mod (addon) | client | frozen-but-works | — | no | 3 | Raid leadership suite; only if bot-raid nights get serious | Win+Wine | https://github.com/ExoJdi/Method-Raid-Tools-3.3.5a |
| Omen | mod (addon) | client | frozen-but-works | — | maybe | 3 | Threat meter — useful learning tool when tanking with bot healers | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Omen.zip |
| ElvUI (3.3.5) | mod (addon) | client | frozen-but-works | DragonUI (one UI) | no | 3 | Full UI replacement; big change for family members who know default UI | Win+Wine | https://github.com/ElvUI-WotLK/ElvUI |
| DragonUI | mod (addon) | client | yes | ElvUI (one UI) | maybe | 3 | Modern Dragonflight-style skin, lighter than ElvUI | Win+Wine | https://github.com/NeticSoul/DragonUI |
| Bartender4 | mod (addon) | client | frozen-but-works | Dominos (one) | maybe | 3 | Action bars; Balih already lives with G13 bindings | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Bartender4.zip |
| Dominos | mod (addon) | client | yes | Bartender4 (one) | maybe | 3 | Simpler bars, maintained (bkader) | Win+Wine | https://github.com/bkader/Dominos |
| MoveAnything | mod (addon) | client | frozen-but-works | — | maybe | 3 | Move any default frame — UI tweaks without a UI replacement | Win+Wine | https://github.com/sirus-addons/MoveAnything |
| Shadowed Unit Frames | mod (addon) | client | frozen-but-works | — | no | 3 | Unit frames; niche | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/ShadowedUnitFrames.zip |
| Grid2 (WotLK) | mod (addon) | client | yes | VuhDo/HealBot (one healing UI) | maybe | 3 | Compact raid frames, maintained | Win+Wine | https://github.com/bkader/Grid2-WoTLK |
| VuhDo | mod (addon) | client | frozen-but-works | one healing UI | maybe | 3 | Healing frames + click-cast — for whoever heals the bot party | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/VuhDo.zip |
| HealBot | mod (addon) | client | frozen-but-works | one healing UI | maybe | 3 | Simplest click-heal — kid-friendly | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/HealBot.zip |
| Clique | mod (addon) | client | frozen-but-works | — | maybe | 3 | Click-casting anywhere | Win+Wine | https://gitlab.com/Tsoukie/clique-3.3.5/-/archive/main/clique-3.3.5-main.zip |
| Decursive | mod (addon) | client | frozen-but-works | — | maybe | 3 | One-click dispels | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Decursive.zip |
| Quartz | mod (addon) | client | frozen-but-works | — | maybe | 3 | Better cast bars with latency window | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Quartz.zip |
| OmniCC | mod (addon) | client | yes | — | maybe | 3 | Cooldown numbers on buttons; tiny + universal | Win+Wine | https://github.com/NoM0Re/OmniCC-WotLK |
| TidyPlates | mod (addon) | client | yes | — | maybe | 3 | Better nameplates, maintained | Win+Wine | https://github.com/bkader/TidyPlates_WoTLK |
| SexyMap | mod (addon) | client | frozen-but-works | — | no | 2 | Minimap bling | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/SexyMap.zip |
| Bagnon (backport) | mod (addon) | client | yes | — | yes | 4 | One-bag inventory with search — the QoL everyone asks for first | Win+Wine | https://github.com/RichSteini/Bagnon-3.3.5 |
| Altoholic | mod (addon) | client | frozen-but-works | — | yes | 4 | Cross-alt inventory/gold tracker — made for our alt-army family | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Altoholic.zip |
| Postal | mod (addon) | client | frozen-but-works | — | yes | 4 | Mass mail open — mandatory once the AH bot floods mailboxes | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Postal.zip |
| WIM | mod (addon) | client | frozen-but-works | — | maybe | 3 | IM-style whisper windows — isolates bot whisper-command traffic; nice with heavy bot use | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/WIM.zip |
| Chatter | mod (addon) | client | frozen-but-works | — | maybe | 3 | Chat QoL (better than Prat on 3.3.5) | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Chatter.zip |
| Auctionator (port) | mod (addon) | client | frozen-but-works | — | maybe | 3 | Simple AH listing — the human side of the AH-bot economy | Win+Wine | https://github.com/alchem1ster/WotLK-Auctionator |
| TradeSkillMaster 2.8.3 | mod (addon) | client | frozen-but-works | — | no | 2 | Gold-making suite; overkill on a family realm | Win+Wine | https://github.com/andrew6180/TradeSkillMaster |
| GearScoreLite Reborn | mod (addon) | client | yes | classic GearScore (RAM leak) | maybe | 3 | Modern GS rewrite without the DB bloat | Win+Wine | https://github.com/Arcitec/GearScoreLite_Reborn |
| RatingBuster | mod (addon) | client | frozen-but-works | — | maybe | 3 | Ratings → real stats in tooltips; teaches gearing | Win+Wine | https://github.com/Einherjarn/RatingBuster-3.3.5 |
| Outfitter | mod (addon) | client | frozen-but-works | — | no | 2 | Gear sets; Shift-compare is native | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Outfitter.zip |
| Titan Panel | mod (addon) | client | frozen-but-works | — | no | 2 | Info bars; taste | Win+Wine | https://legacy-wow.com/wotlk-addons/titan-panel/ |
| MobInfo2 | mod (addon) | client | no | — | no | 2 | Legacy mob data tooltips | Win+Wine | https://felbite.com/wow-3-3-5-addons/ |
| Addon Control Panel | mod (addon) | client | frozen-but-works | — | maybe | 3 | Toggle addons in-game — saves relogs while tuning the family set | Win+Wine | https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/ACP.zip |
| AddOns-Update-Tool | helper app | client | yes | — | no | 3 | Bulk addon updater; Windows app (family PCs could use it; Wine box syncs manually) | Windows only | https://github.com/alchem1ster/AddOns-Update-Tool |
| AwesomeWotlk | mod (patch) | client | yes | some nameplate addons REQUIRE it | maybe | 4 | DLL patch: FoV, long camera, modern nameplate APIs — the modern client enhancer; TEST ON WINE FIRST | Win (Wine: test) | https://github.com/FrostAtom/awesome_wotlk |
| HD Down-port (WoD models) | mod (patch) | client | frozen-but-works | NOT mixable with Upscaled Remaster | maybe | 3 | HD characters/creatures from WoD/Legion; big download; occasional model crashes; LAA flag REQUIRED first | Win+Wine (MPQ) | https://forum.warmane.com/showthread.php?t=456935 |
| HD Upscaled Remaster | mod (patch) | client | frozen-but-works | NOT mixable with Down-port pack | maybe | 3 | AI-upscaled textures keeping original art style — the tasteful HD option; drop patch-k MPQ if mount-window crashes | Win+Wine (MPQ) | https://forum.warmane.com/showthread.php?t=467314 |
| Warmane HD (modular) | mod (patch) | client | frozen-but-works | other HD packs | maybe | 3 | Pick-and-choose HD MPQs; rename to your locale | Win+Wine (MPQ) | https://forum.warmane.com/showthread.php?t=464195 |
| View-distance unlock exe | mod (patch) | client | frozen-but-works | AwesomeWotlk overlap | no | 2 | Patched Wow.exe; prefer AwesomeWotlk | Win (Wine: test) | https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-emulator-servers/wow-emu-programs/617938-vanilla-1-12-1-tbc-2-4-3-wotlk-3-3-5a-view-distance-unlock-patched-wow-exe.html |
| Large Address Aware flag | mod (patch) | client | frozen-but-works | — | yes (if any HD pack) | 4 | 4GB flag on Wow.exe — REQUIRED before HD packs or the 32-bit client crashes; flag survives Wine; flagging tool is Windows | tool: Windows | https://www.techpowerup.com/forums/threads/large-address-aware.112556/ |
| Camera distance CVars | tweak | client | native | — | yes | 4 | `/console cameraDistanceMaxFactor 4` — free, built-in, do it on every client | Win+Wine | (native — no download) |

---

*Compiled 2026-08-01 by Auren from three parallel research sweeps (official org API census,
community topic search [403 repos → top ~85], client-side source review). Ratings and
recommendations are opinions calibrated to THIS realm; verify each repo before cloning,
as the guide's own rule says.* 🪶
