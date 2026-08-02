# <img src="assets/icons/prerequisite-zero.png" class="nk-title-icon" alt=""> Optional — Client: mods + add-ons

**This page is the client half of the Optionals** — everything you install on the
*player's* computer, not the Pi. Its sibling is
[Server: modules + add-ons](optional-modules.md). Everything in the **installed kit**
below was installed and play-tested on this realm's reference client (August 2026);
the [More to explore](#-more-to-explore-curated-not-yet-tested) section at the end is
curated but not yet tested.

It's written for a **Windows** player joining the realm (this is the page to send your
family), with the Linux/Wine paths noted where they differ. You install everything
one at a time, checking each works before the next — same rule as the server side.

## Before you start

1. **The game must already run.** Client installed and connecting to the realm
   (Chapter 08, or the join-the-realm instructions you were sent).
2. **Know your client folder** — the folder that contains `Wow.exe`. On Windows this
   guide assumes `C:\Games\World of Warcraft`; adjust if yours lives elsewhere.
   On the Linux reference client it's `~/Games/ChromieCraft_3.3.5a`.
3. **Install [7-Zip](https://www.7-zip.org/)** (Windows, free). Regular zips Windows
   opens natively, but the graphics pack in Part 2 is a password-protected `.7z` that
   needs it.

## The three golden rules of 3.3.5a add-ons

1. **Add-ons are folders**, and they live in `<client>\Interface\AddOns\`. Installing
   is literally: unzip → move folder(s) in. Uninstalling is deleting the folder.
2. **The folder name must match what's inside.** Each add-on folder contains a `.toc`
   file with the same name as the folder (`Postal\Postal.toc`). GitHub's "Download ZIP"
   often wraps everything in a `something-master` folder — **the folder with the `.toc`
   inside is the one that goes into `AddOns\`**, renamed to drop any `-master`/`-main`
   suffix. Every step below tells you exactly which folders you should end up with.
3. **Tick "Load out of date AddOns."** At the character-select screen, click the
   **AddOns** button (bottom-left) and check the box, once. These add-ons predate
   nothing — the *game* is what's old — but the client is paranoid about version
   numbers.

> **Do the add-ons one at a time.** Install one, launch, log in, run its check, quit,
> next. When something breaks after 11 installs at once, you learn nothing; one at a
> time, the culprit identifies itself.

## Part 1 — The installed kit (11 add-ons)

The order below is deliberate: the first three change how you *play*, the rest are
comfort. Stop wherever you like — every one is independent.

### 1. pfQuest — quest helper

**What/why:** puts quest givers and objectives on your map and minimap — the single
biggest modernization for questing. We run shagu's pfQuest (WotLK build).

- **Download:** [pfQuest-enUS-wotlk.zip (v7.0.1)](https://github.com/shagu/pfQuest/releases/download/7.0.1/pfQuest-enUS-wotlk.zip)
- **Install:** unzip → move the **`pfQuest-wotlk`** folder into `AddOns\`. (1 folder)
- **Check:** log in — quest icons appear on the world map (`M`). Type `/db config`
  to see its settings window.

> **First thing on every character: type `/db query`.** pfQuest learns quest
> completion as you play, so on a character with history it shows already-finished
> quests as available — ghost `!` markers orbiting your minimap. `/db query` asks the
> *server* for that character's true completed list and fixes the markers on the spot.
> Once per existing character; brand-new characters don't need it.

### 2. Atlas — instance maps

**What/why:** WotLK dungeons have no in-game maps; Atlas adds them all.

- **Download:** [Atlas.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Atlas.zip)
- **Install:** unzip → move **`Atlas`, `Atlas_Battlegrounds`, `Atlas_DungeonLocs`,
  `Atlas_OutdoorRaids`, `Atlas_Transportation`** into `AddOns\`. (5 folders)
- **Check:** `/atlas` opens the map browser.

### 3. AtlasLoot — loot tables

**What/why:** browse what every boss drops before you go — how the family decides
tonight's dungeon.

- **Download:** [AtlasLoot.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/AtlasLoot.zip)
- **Install:** unzip → move **`AtlasLoot`, `AtlasLootFu`, `AtlasLoot_OriginalWoW`,
  `AtlasLoot_BurningCrusade`, `AtlasLoot_WrathoftheLichKing`, `AtlasLoot_Crafting`,
  `AtlasLoot_WorldEvents`** into `AddOns\`. (7 folders)
- **Check:** `/atlasloot` opens the loot browser; boss pages in Atlas now show a loot
  button.

### 4. Deadly Boss Mods (DBM) — boss timers

**What/why:** the classic raid-warning add-on: timers and alarms for boss abilities in
every dungeon and raid. The Warmane fork is the maintained one for 3.3.5a.

- **Download:** [DBM-Warmane 10.1.12](https://github.com/Zidras/DBM-Warmane/archive/refs/tags/10.1.12.zip)
- **Install:** unzip → open the **`DBM-Warmane-10.1.12`** wrapper folder → move **all
  36 `DBM-*` folders** (`DBM-Core`, `DBM-GUI`, `DBM-Party-WotLK`, …) into `AddOns\`.
  This is the one add-on where you move *everything inside the wrapper*, not the
  wrapper itself.
- **Check:** `/dbm` opens its window.

### 5. GTFO — "you're standing in fire"

**What/why:** plays a loud alert the instant you stand in damaging ground effects.
Family-approved.

- **Download:** [GTFO.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/GTFO.zip)
- **Install:** unzip → move **`GTFO`** into `AddOns\`. (1 folder)
- **Check:** `/gtfo help` responds in chat.

### 6. Skada — damage meter

**What/why:** who did the damage, who did the healing — settle it with data.

- **Download:** [Skada-WotLK 1.8.87](https://github.com/bkader/Skada-WoTLK/releases/download/1.8.87/Skada-WotLK-1.8.87.zip)
- **Install:** unzip → move **`Skada`** into `AddOns\`. (1 folder)
- **Check:** a meter window appears; `/skada` for options.

### 7. Bagnon — one-bag inventory

**What/why:** merges all your bags into a single searchable window.

- **Download:** [Bagnon-3.3.5](https://github.com/RichSteini/Bagnon-3.3.5/archive/refs/heads/main.zip)
- **Install:** unzip → open the **`Bagnon-3.3.5-main`** wrapper → move **`Bagnon`,
  `Bagnon_Config`, `Bagnon_Forever`, `Bagnon_GuildBank`, `Bagnon_Tooltips`,
  `Bagnon_VoidStorage`** into `AddOns\`. (6 folders)
- **Check:** press `B` — one big bag.

### 8. Postal — mailbox sanity

**What/why:** "Open All" for your mailbox instead of clicking 50 attachments.

- **Download:** [Postal.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Postal.zip)
- **Install:** unzip → move **`Postal`** into `AddOns\`. (1 folder)
- **Check:** visit a mailbox — new buttons on the mail window.

### 9. Altoholic — know your alts

**What/why:** tracks every character's gold, bags, professions, and mail — across your
whole account. Shines once the family has a roster of alts.

- **Download:** [Altoholic.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/Altoholic.zip)
- **Install:** unzip → move **`Altoholic`, `Altoholic_Achievements`** and **all 16
  `DataStore*` folders** into `AddOns\`. (18 folders — DataStore is Altoholic's
  database engine, required.)
- **Check:** `/altoholic` opens the summary.

### 10. TurnIn — instant quest turn-ins

**What/why:** auto-accepts and auto-completes quest dialogue — no clicking through
text walls. (Toggle per session if someone prefers reading the quests!)

- **Download:** [TurnIn-2.1.zip](https://github.com/NoM0Re/WoW-3.3.5a-Addons/raw/main/src/Addons/TurnIn-2.1.zip)
- **Install:** unzip → move **`TurnIn`** into `AddOns\`. (1 folder)
- **Check:** `/ti` shows its status; talk to a quest giver and watch it fly.

### 11. UnBot — bot control panel

**What/why:** the Playerbots special — a clickable panel for ordering your bot party
around (formations, strategies, gear checks) instead of typing whisper commands.
Comes with YssBossLoot as a bundled helper.

- **Download:** [unbot-addon](https://github.com/liyunfan1223/unbot-addon/archive/refs/heads/master.zip)
  (from the same author ecosystem as the Playerbots fork itself)
- **Install:** unzip → open the **`unbot-addon-master`** wrapper → move **`UnBot`**
  and **`YssBossLoot`** into `AddOns\`. (2 folders)
- **Check:** `/ub` toggles the bot panel. Closed it by accident mid-session? `/ub`
  brings it back.

**Final count:** with everything above installed, `Interface\AddOns\` holds **79**
non-Blizzard folders. Character-select's AddOns button should list them all.

## Part 2 — HD graphics: the WoD/Legion models pack

**What it is:** a community pack that swaps the 2008 character, mount, and NPC models
for the modern high-poly ones (down-ported from Warlords of Draenor / Legion), plus
optional high-res armor and environment textures. Collected by ALIESS on the
[Warmane forums](https://forum.warmane.com/showthread.php?t=456935) from the work of
Truekripp, Finsternis, Leeviathan, Nicola, Inico, and others. **Purely client-side and
purely visual** — the server never knows, and players with and without it can play
together.

> **One graphics pack at a time.** Packs of this kind claim the same `patch-*.MPQ`
> slots and overwrite overlapping assets. Mixing two means glitches at best. Remove
> one completely (delete its MPQ files) before trying another.

### 2.1 Download

- **File:** `WoW-HD-3.3.5-v3.7z` — **6.5 GB** (yes, really — it's most of a game's
  worth of models):
  [Google Drive link](https://drive.google.com/file/d/1WHKkauuIefEWzZ1Qausc24t--XXZIz2_/view)
- Google Drive will warn it "can't scan for viruses" at this size — Download anyway.
- The archive is password-protected. The password is a single forward slash:

  ```
  /
  ```

### 2.2 Extract and choose your patches

Right-click the `.7z` → 7-Zip → Extract (enter the `/` password). Inside: a `Data`
folder of MPQ patches, a `Patch_Lables.txt` describing them, and `Wow-HD.exe`.

The pack is modular — each MPQ is independent, and each is removable later by
deleting that one file. What we run on the reference client:

| File | What it adds | Size |
|---|---|---|
| `patch-H.mpq` | **HD character models** — the main event | 2.1 GB |
| `patch-F.mpq` + `patch-G.mpq` | Mounts, druid forms, NPCs (a pair — both or neither) | 835 MB |
| `patch-D.mpq` | HD goblins | 78 MB |
| `patch-8.mpq` | High-res armor textures — so HD characters don't wear blurry gear | 2.4 GB |
| `patch-L.mpq` | HD login + character-select screens and icons | 122 MB |
| `patch-S/T/W/X/Y.mpq` | Environment: sunlight, tilesets, water, trees, blood | ~465 MB |

Skipped on the reference client: `patch-4`/`patch-5` (music), `patch-M` (loading
screens), and `patch-I`/`patch-Q`/`patch-R` (undocumented in the pack's own labels
file — we don't install what we can't name).

**Install:** copy your chosen `patch-*.mpq` files into the client's **`Data\`** folder
(next to the big `common.MPQ`/`patch.MPQ` originals). Nothing gets overwritten — these
are all new filenames.

### 2.3 The `Wow-HD.exe` launcher (required)

Copy **`Wow-HD.exe`** from the pack into the client folder, **next to** `Wow.exe`
(don't delete or rename the original!). From now on, **launch `Wow-HD.exe` instead of
`Wow.exe`** — update your shortcut.

Why: the HD models need two things the stock exe lacks — 4 GB memory support (the
32-bit client normally caps at 2 GB, and these models are hungry) and a small
model-shader fix (without it, HD characters render with glitched lighting). We
byte-compared `Wow-HD.exe` against the stock exe before trusting it: identical file,
97 bytes changed — exactly those two patches, nothing else.

### 2.4 Windows 11: compatibility mode

The pack's maintainer (and years of thread reports) are unambiguous: **on Windows 11,
set compatibility mode or the client crashes.** Right-click `Wow-HD.exe` →
**Properties → Compatibility** → check **"Run this program in compatibility mode
for:"** → pick **Windows 7** → OK. Windows 10 and Wine/Linux don't need this.

### 2.5 First launch

1. Delete the **`Cache`** folder in the client directory (the game rebuilds it;
   stale cache is the #1 cause of post-patch weirdness).
2. Launch `Wow-HD.exe`.
3. Proof it worked before you even log in: the **login and character-select screens
   are new** (that's `patch-L`). In game, your character and gear look modern
   (`patch-H` + `patch-8`); mount up for `patch-F`/`patch-G`.

### Removing it

Delete the lowercase `patch-*.mpq` files you added to `Data\` (the pack's files are
easy to spot — the client's originals are the handful of UPPERCASE-`.MPQ` ones),
delete the `Cache` folder, and launch plain `Wow.exe` again. Total rollback, nothing
to reinstall.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Add-on doesn't appear in the AddOns list | Folder nesting — you copied the wrapper (`X-master`) instead of the folder with the `.toc` in it. Also confirm "Load out of date AddOns" is ticked. |
| Ghost `!` quest markers orbiting the minimap | pfQuest doesn't know your pre-addon history — type `/db query` on that character. |
| Crash at launch after installing graphics (Win 11) | Compatibility mode on `Wow-HD.exe` (§2.4). |
| Glitched character lighting / crashes with HD models | You launched plain `Wow.exe` — the HD pack needs `Wow-HD.exe`. Then delete `Cache` and retry. |
| Weirdness right after any MPQ change | Delete the `Cache` folder. Always the first move. |
| Closed the bot panel | `/ub` toggles it back. |

## 🧭 More to explore (curated, not yet tested)

Verified-alive in July 2026 but **not yet installed on this realm** — treat as a
vetted shopping list. Entries get promoted into the kit above (or dropped) as we
actually run them.

| Add-on | What it does | Source |
|---|---|---|
| MultiBot | Visual bot-control panel, an alternative to UnBot | [Wishmaster117/MultiBot-Chatless](https://github.com/Wishmaster117/MultiBot-Chatless) |
| Playerbot Manager | Tracks bots' gear and raid composition | [Lichborne-AC/PlayerbotManager](https://github.com/Lichborne-AC/PlayerbotManager) |
| CompactRaidFrame | Modern raid frames backport — pairs well with a bot raid | [Tsoukie/compactraidframe-3.3.5](https://gitlab.com/Tsoukie/compactraidframe-3.3.5) |
| Questie | The other quest helper — explicitly matched to AzerothCore data. We chose pfQuest; if it ever disappoints, this is the replacement | [Aldori15/Questie](https://github.com/Aldori15/Questie) |
| Leatrix Plus | Automation suite: auto-sell junk, auto-repair, speed tweaks | [Sattva-108/Leatrix_Plus](https://github.com/Sattva-108/Leatrix_Plus) |
| WeakAuras | Graphical trigger framework: procs, cooldowns, custom displays | [Bunny67/WeakAuras-WotLK](https://github.com/Bunny67/WeakAuras-WotLK) |
| Immersion | Retail-style animated quest dialogue | [s0h2x/Immersion-WotLK](https://github.com/s0h2x/Immersion-WotLK) |
| GSE | One-button rotation macros | [cerberuscx/GSE-WotLK-3.3.5a](https://github.com/cerberuscx/GSE-WotLK-3.3.5a) |
| ElvUI | Full UI replacement | [ElvUI-WotLK/ElvUI](https://github.com/ElvUI-WotLK/ElvUI) |
| Auctionator / DalaranAH | Saner auction-house UI — becomes relevant once the server's AH bot (Batch B) populates the auction house | [jejkas/Auctionator](https://github.com/jejkas/Auctionator) · [NoM0Re/DalaranAH](https://github.com/NoM0Re/DalaranAH) |

**Finding more:** [NoM0Re/WoW-3.3.5a-Addons](https://github.com/NoM0Re/WoW-3.3.5a-Addons)
— an actively curated, categorized index of hundreds of 3.3.5a add-ons (several of the
kit's downloads above come straight from it).

## Status

**The 11-add-on kit + the HD models pack: installed and play-tested on the reference
client, August 2026.** Rule unchanged: what's written here is what actually happened.
For the server half — modules compiled into the worldserver — see
[Server: modules + add-ons](optional-modules.md).
