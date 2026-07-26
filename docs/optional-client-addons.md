# Optional — Client add-ons

The 3.3.5a modding scene has quietly revived: maintainers keep backporting modern Retail
and Classic features into the old 12340 client. This page is a **curated, link-verified**
list of add-ons that improve a solo Playerbots realm — bot control panels, questing maps,
boss timers, full UI overhauls.

> **Status: curated, not yet validated by this guide.** Every link below was verified
> live (July 2026) with maintainer and last-activity checked — but we have not yet
> installed and play-tested them on this realm. That pass happens after the validation
> loop rebuild. Treat this page as a vetted shopping list, not a tested chapter; entries
> get promoted (or dropped) as we actually run them. Found one broken or better?
> [Open an issue](https://github.com/jetomev/pi-kognog-azerothcore/issues).

## Installing any add-on (the 60-second version)

1. Download the add-on (GitHub: **Code → Download ZIP**, or a release zip).
2. Extract it into your client's add-on folder:
   `<client>/Interface/AddOns/` — for this guide's reference client,
   `~/Games/ChromieCraft_3.3.5a/Interface/AddOns/`.
3. **Remove any `-master` / `-main` suffix** from the extracted folder name — the folder
   must match the add-on's internal name or the game won't see it. Some repos wrap the
   real add-on one level deep; the folder containing the `.toc` file is the one that goes
   in `AddOns/`.
4. At the character-select screen, open **AddOns** (bottom-left) and tick
   **Load out of date AddOns**.

## 🛠️ Bot management (the Playerbots specials)

These exist *because of* mod-playerbots — GUI control instead of typing chat commands.
The first two are listed on the fork's own
[Playerbot Addons wiki page](https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Addons-and-Sub%E2%80%90Modules).

| Add-on | What it does | Source | Health |
|---|---|---|---|
| **MultiBot** | Visual panel for bot control — summon, gear, strategies, roles — no chat typing | [Wishmaster117/MultiBot-Chatless](https://github.com/Wishmaster117/MultiBot-Chatless) | ✅ active (2026) |
| **Playerbot Manager** | Tracks your bots' gear and raid composition | [Lichborne-AC/PlayerbotManager](https://github.com/Lichborne-AC/PlayerbotManager) | ✅ active (2026) |
| **CompactRaidFrame** | Modern raid frames backport — pairs well with a bot raid | [Tsoukie/compactraidframe-3.3.5](https://gitlab.com/Tsoukie/compactraidframe-3.3.5) | ✅ wiki-recommended |
| PlayerbotsPanel | Early GUI wrapper for bot commands | [azcguy/PlayerbotsPanel](https://github.com/azcguy/PlayerbotsPanel) | ⚠ alpha, stalled 2024 |

## 💎 Quality of life

| Add-on | What it does | Source | Health |
|---|---|---|---|
| **Leatrix Plus** | The automation suite: auto-accept/turn-in quests, auto-sell junk, auto-repair, chat and speed tweaks | [Sattva-108/Leatrix_Plus](https://github.com/Sattva-108/Leatrix_Plus) | ✅ active (2026) |
| **GSE** (GnomeSequencer Enhanced) | Single-button sequence macros past the 255-character limit — one key, full rotation | [cerberuscx/GSE-WotLK-3.3.5a](https://github.com/cerberuscx/GSE-WotLK-3.3.5a) | ✅ 2025 revival, active |

## 🗺️ Questing & immersion

| Add-on | What it does | Source | Health |
|---|---|---|---|
| **Questie** | Quest markers on map and minimap — the modern questing experience. This fork is explicitly built to match **AzerothCore** data | [Aldori15/Questie](https://github.com/Aldori15/Questie) | ✅ active (2026) — the pick for this realm |
| **Immersion** | Replaces quest text walls with the Retail-style animated talking-head dialogue | [s0h2x/Immersion-WotLK](https://github.com/s0h2x/Immersion-WotLK) | ✅ stable (2024) |
| pfQuest-wotlk | Alternative quest helper (shagu's pfQuest, WotLK build) | [Bennylavaa/pfQuest-wotlk](https://github.com/Bennylavaa/pfQuest-wotlk) | ✅ maintained — but Questie fits AzerothCore better |

## ⚔️ Combat & raiding

| Add-on | What it does | Source | Health |
|---|---|---|---|
| **WeakAuras** | The graphical trigger framework: procs, cooldowns, missing buffs, custom displays | [Bunny67/WeakAuras-WotLK](https://github.com/Bunny67/WeakAuras-WotLK) | ✅ canonical backport, stable (2024) |
| **DBM** (Deadly Boss Mods) | Boss timers, warnings, and mechanics alerts for dungeons and raids — also the fork the Playerbots wiki recommends | [Zidras/DBM-Warmane](https://github.com/Zidras/DBM-Warmane) | ✅ active (2026) — works on any 3.3.5 realm |
| BigDebuffs | Overlays crowd-control and immunities on frames and nameplates | [ManneN1/BigDebuffs-WotLK](https://github.com/ManneN1/BigDebuffs-WotLK) | ✅ stable (2024) |
| BattlegroundTargets | Clickable enemy frames for battlegrounds, with flag-carrier and healer detection | [KhalGH/BattlegroundTargets-WotLK](https://github.com/KhalGH/BattlegroundTargets-WotLK) | ✅ maintained (2025) |

## 🎨 Interface overhauls

| Add-on | What it does | Source | Health |
|---|---|---|---|
| **ElvUI** | The full UI replacement: action bars, unit frames, chat, maps — one unified, customizable layout | [ElvUI-WotLK/ElvUI](https://github.com/ElvUI-WotLK/ElvUI) | ✅ mature/complete (2024); org includes ElvUI_Enhanced and AddOnSkins |
| GudaBags | One-window bags with smart sorting, search, and bank view | [GudaLegacy/GudaBags](https://github.com/GudaLegacy/GudaBags) | ⚠ active (2026) but README targets a modified 3.3.5a client — **test on stock 12340** |
| AtlasLoot | Browse loot tables in-game — this build restores Naxx-40/Onyxia-40 era tables | [Day36512/Atlas-Loot-Individual-Progression-3.3.5](https://github.com/Day36512/Atlas-Loot-Individual-Progression-3.3.5) | ✅ active (2026); pairs with `mod-individual-progression` |
| Auctionator | Saner auction-house UI — worth it once `mod-ah-bot` populates the AH | [jejkas/Auctionator](https://github.com/jejkas/Auctionator) | ✅ recent (2025) |

## Finding more

**[NoM0Re/WoW-3.3.5a-Addons](https://github.com/NoM0Re/WoW-3.3.5a-Addons)** — an actively
curated index of the most useful 3.3.5a add-ons (hundreds, categorized). When you want
something this page doesn't cover, start there. (Classics like **Postal** are distributed
through indexes like this one; no single canonical 3.3.5 repo exists for it, so we won't
invent one.)

## ✅ When this page graduates

After the validation-loop rebuild, add-ons get installed and play-tested on this realm one
at a time — working ones get marked tested, broken ones get dropped or annotated. Same
rule as the server: what's written here must be what actually happened.
