# <img src="assets/icons/why-this-guide-exists.png" class="nk-title-icon" alt=""> Troubleshooting

Every problem we actually hit, with the exact error text and what fixed it. Entries are added **as they happen**, not remembered afterwards.

Search this file by the error message. That is how you will arrive here.

**Jump to a chapter:**
[00 — Provisioning](#chapter-00--provisioning-the-pi) ·
[01 — Client & game data](#chapter-01--the-client-and-extracting-game-data) ·
[03 — Database](#chapter-03--mysql-and-the-databases) ·
[04 — Cloning](#chapter-04--cloning-azerothcore--the-playerbots-fork) ·
[05 — Building](#chapter-05--building) ·
[07 — First boot](#chapter-07--first-boot) ·
[08 — Client side](#chapter-08--the-client-side) ·
[09 — Bot party](#chapter-09--your-bot-party) ·
[10 — Keeping it alive](#chapter-10--keeping-it-alive)

## How entries are written

Entries are grouped under the chapter they occurred in. Each one looks like:

```
### <short symptom>

**Symptom:** the literal error output, verbatim
**Cause:** what was actually wrong
**Fix:** the commands or change that resolved it
**ARM64-specific:** yes / no
```

The `ARM64-specific` flag matters: it tells an x86 reader whether an entry is relevant to them, and it tells an ARM reader which problems are the ones nobody else has written about.

---

<a id="chapter-00--provisioning-the-pi"></a>

## Chapter 00 — Provisioning the Pi

### NVMe not detected (`link down`), even with the HAT LEDs lit

**Symptom:** No `nvme0n1` in `lsblk`. The kernel log shows the external PCIe port
finding nothing:

```
brcm-pcie 1000110000.pcie: Forcing gen 2
brcm-pcie 1000110000.pcie: link down
brcm-pcie 1000120000.pcie: link up, 5.0 GT/s PCIe x4
```

The HAT's LEDs were on the whole time, which made it look like the drive should work.

**Cause:** Two separate traps, both of which cost us two days:
1. **The HAT's LEDs are not wired to the PCIe link.** On a PoE / self-powered HAT the
   LEDs light from that power source the instant it is present, completely independent
   of whether an NVMe is connected, seated, or alive. "Lights on" tells you the HAT has
   power and **nothing** about the drive.
2. **The drives themselves were the fault.** We had three NVMe sticks that would not
   enumerate on any Pi or HAT, while a known-good drive worked in every slot. Bad or
   incompatible drives produce exactly this `link down`, silently.

Note the two PCIe controllers in the log: `1000120000` (internal, the RP1 I/O chip)
always trains — that is not your drive. `1000110000` is the **external** slot; that is
the one that must say `link up` for your HAT.

**Fix:** Isolate methodically, and do not trust the LEDs.
- Confirm the stick is **NVMe (one notch), not SATA (two notches)**. A SATA M.2 stick
  will never work in an NVMe HAT.
- Swap in a **known-good NVMe** in the same slot. If it enumerates, the original drive
  was the fault.
- Move a drive to a **different Pi/HAT**, or into a desktop M.2 slot, to prove whether
  the drive or the HAT is at fault.
- `config.txt` needs **no** special PCIe setting for a standard HAT on a Pi 5 — the
  external port initialises on its own. If the port says `link down`, the problem is
  physical (drive, seating, or HAT), not configuration. Do not go editing `config.txt`.

**ARM64-specific:** yes

---

### Raspberry Pi Imager "customisation" options are greyed out

**Symptom:** In Raspberry Pi Imager, after choosing an **Ubuntu** image, the OS
customisation dialog (hostname, user, SSH, Wi-Fi) is present but unavailable — you
cannot fill it in.

**Cause:** Imager's built-in customisation is a **Raspberry Pi OS** feature. It does not
apply to Ubuntu images. Ubuntu configures itself from a **cloud-init `user-data`** file
on the boot partition instead.

**Fix:** Flash the Ubuntu image, then edit `user-data` on the `system-boot` partition as
shown in Chapter 00, Step 3. Do not look for the setting in Imager; it will never be
available for Ubuntu.

**ARM64-specific:** no (Raspberry-Pi-specific)

---

### Telling Ubuntu Desktop from Server after flashing

**Symptom:** You are not sure whether you flashed Ubuntu **Server** or **Desktop** (it
matters — Desktop drags in a GUI you will never use on a headless server).

**Cause:** The download name is easy to misremember, and both boot to a similar first
prompt over serial/console.

**Fix:** Do not trust the filename; inspect the installed system:

```
dpkg -l | grep -E 'ubuntu-desktop|gdm3|gnome-shell'   # Server: no output
df -h /                                                # Server root is far smaller
```

If desktop packages are present, reflash with the **Server** edition.

**ARM64-specific:** no

---

### `Permission denied (publickey)` on the first SSH

**Symptom:**

```
tphome@192.168.1.x: Permission denied (publickey).
```

The Pi is up and pingable, and password auth is (correctly) disabled.

**Cause:** Usually a **client-side** problem, not the Pi. The server offering
publickey-only is exactly what we configured. Common causes: the private key is
passphrase-protected and no `ssh-agent` is running to supply it in a non-interactive
context, or `-i` was pointed at the `.pub` (public) file instead of the private key.

**Fix:**
- Point `-i` at the **private** key (the file **without** `.pub`):
  `ssh -i ~/.ssh/id_ed25519_tpgaming tphome@<ip>` and enter the passphrase when asked.
- Verify the key is the right one and, if you expected agent-based auth,
  `ssh-add ~/.ssh/id_ed25519_tpgaming` first.
- Only after ruling out the client should you suspect the Pi. A `Permission denied
  (publickey)` is not proof the machine is misconfigured.

**ARM64-specific:** no

---

<a id="chapter-01--the-client-and-extracting-game-data"></a>

## Chapter 01 — The client and extracting game data

### jemalloc fails to compile: `'__throw_bad_alloc' is not a member of 'std'`

**Symptom:** Building the extractor tools dies on the bundled jemalloc:

```
deps/jemalloc/src/jemalloc_cpp.cpp:70:22: error:
  '__throw_bad_alloc' is not a member of 'std'; did you mean '__throw_bad_cast'?
make: *** [map_extractor] Error 2
```

**Cause:** AzerothCore vendors an old copy of the jemalloc allocator whose C++ shim used
a libstdc++ internal that **new compilers no longer expose** (seen on GCC 16). It has
nothing to do with the extractors — they do not even need jemalloc.

**Fix:** Disable jemalloc at configure time. It is a supported AzerothCore option:

```
cmake .. -DNOJEM=1  ...   # (re-run cmake with the flag, then rebuild)
```

On an older/stable toolchain (e.g. Ubuntu's default GCC) you may never hit this and can
omit the flag.

**ARM64-specific:** no (compiler-version-specific)

---

### `MYSQL_INCLUDE_DIR-NOTFOUND` when building only the tools

**Symptom:**

```
CMake Error in src/server/database/CMakeLists.txt:
  Imported target "mysql" includes non-existent path "MYSQL_INCLUDE_DIR-NOTFOUND"
```

**Cause:** AzerothCore's top-level CMake adds the `server` directory **unconditionally**,
and its database component checks for MySQL/MariaDB client headers — even when you only
intend to build the extractor tools.

**Fix:** Install the MariaDB client library so the header check passes. You do **not**
need a running database on this machine.

```
sudo pacman -S --needed mariadb-libs      # Arch
# Debian/Ubuntu equivalent: libmariadb-dev  (or default-libmysqlclient-dev)
```

**ARM64-specific:** no

---

### `-DTOOLS=1` is ignored / CMake builds the whole server

**Symptom:** You pass `-DTOOLS=1 -DSERVERS=0`, CMake warns they are "unused", and it
configures the full server anyway.

**Cause:** Those are not the current option names. AzerothCore selects tools with a
**string** variable, `TOOLS_BUILD`.

**Fix:**

```
cmake .. -DTOOLS_BUILD=all -DSCRIPTS=none ...
```

`TOOLS_BUILD=all` builds every tool; you can also name specific ones. Confirm the CMake
output shows a "Tools build list" including `map_extractor`, `vmap4_extractor`,
`vmap4_assembler`, `mmaps_generator`.

**ARM64-specific:** no

---

### `mmaps_generator` aborts: "Failed to load configuration ... mmaps-config.yaml"

**Symptom:**

```
Failed to load configuration. Ensure that 'mmaps-config.yaml' exists in the current
directory or specify its path using the --config option.
```

**Cause:** Current `mmaps_generator` requires a config file that older versions did not.
It looks for `mmaps-config.yaml` in the working directory.

**Fix:** Copy it from the source tree into your extraction workspace before running:

```
cp ~/azerothcore-tools/src/tools/mmaps_generator/mmaps-config.yaml .
```

**ARM64-specific:** no

---

### `MMAP: … was built with generator v20, expected v19` (bots/creatures won't move)

**Symptom:** The server boots, but the load is full of lines like:

```
MMAP:loadMap: 5712834.mmtile was built with generator v20, expected v19
MoveSplineInitArgs::Validate: expression 'velocity > 0.01f' failed for GUID ...
```

Bots stand frozen or fail to path.

**Cause:** The navigation meshes (`mmaps`) carry a format version. The **Playerbots fork
expects v19**; **upstream AzerothCore's extractor produces v20**. If you built the Chapter
01 extractor tools from upstream instead of the fork, every mmap tile is the wrong version
and the server rejects them all — so there's no navmesh and nothing can move. (The
`maps`/`vmaps` share a version and are unaffected; only `mmaps` break.)

**Fix:** Regenerate the mmaps with the **fork's** `mmaps_generator`. On the desktop:

```
git clone --depth 1 --branch Playerbot https://github.com/mod-playerbots/azerothcore-wotlk.git ~/azeroth-fork
cd ~/azeroth-fork && mkdir build && cd build
cmake .. -DTOOLS_BUILD=all -DSCRIPTS=none -DNOJEM=1 -DCMAKE_BUILD_TYPE=Release
make -j$(nproc) mmaps_generator
# then, in your extraction workspace (with maps/ and vmaps/ present):
cp ~/azeroth-fork/build/src/tools/mmaps_generator .
cp ~/azeroth-fork/src/tools/mmaps_generator/mmaps-config.yaml .
rm -rf mmaps && mkdir mmaps && ./mmaps_generator --threads $(( $(nproc) - 1 ))
```

Then re-transfer just the `mmaps` folder to the Pi (rsync with `--delete`). Confirm a tile
header reads version 19: `od -An -tu4 -N16 mmaps/<any>.mmtile` (third number = 19). The
better fix is to build the Chapter 01 tools from the fork in the first place.

**ARM64-specific:** no

---

<a id="chapter-03--mysql-and-the-databases"></a>

## Chapter 03 — MySQL and the databases

### `AzerothCore does not support MySQL versions below 8.0` (you're on MariaDB)

**Symptom:** worldserver connects to the database, then quits:

```
AzerothCore does not support MySQL versions below 8.0
Found server version: 5.5.5-10.11.14-MariaDB. Server compiled with: 80046.
```

**Cause:** **AzerothCore dropped MariaDB support in September 2024** and requires MySQL
8.0+. MariaDB reports its version with a legacy `5.5.5-` prefix, which AzerothCore reads as
"below 8.0" and rejects. This is not a version-detection bug you can work around — MariaDB
is genuinely unsupported.

**Fix:** Replace MariaDB with MySQL 8.0 (Ubuntu's own repo; matches the client the server
was built against). Your databases are recreated empty, so nothing is lost if you haven't
booted yet:

```
sudo systemctl stop mariadb
sudo apt purge -y mariadb-server mariadb-server-core
sudo apt autoremove -y --purge
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
```

Then recreate the databases (Chapter 03) and retry. **Do not** blanket-`rm -rf /etc/mysql`
during this — see the next entry.

**ARM64-specific:** no

---

### MySQL install fails: `Can't read dir of '/etc/mysql/conf.d/'`

**Symptom:** Installing `mysql-server` aborts with:

```
mysqld: Can't read dir of '/etc/mysql/conf.d/' (OS errno 2 - No such file or directory)
mysqld: [ERROR] Fatal error in defaults handling. Program aborted!
dpkg: error processing package mysql-server-8.0
```

**Cause:** You ran `rm -rf /etc/mysql` while the `mysql-common` package was still installed.
That deleted files the package owns; since the package wasn't reinstalled, they were never
recreated, and MySQL's `my.cnf` `!includedir /etc/mysql/conf.d/` then points at a missing
directory.

**Fix:** Recreate the directory skeleton, restore the config, and finish the install:

```
sudo mkdir -p /etc/mysql/conf.d /etc/mysql/mysql.conf.d
sudo apt install --reinstall -y mysql-common
sudo dpkg --configure -a
sudo apt --fix-broken install -y
sudo systemctl restart mysql
```

Avoid the blanket `rm -rf` in the first place — a targeted `apt purge` is enough.

**ARM64-specific:** no

---

<a id="chapter-04--cloning-azerothcore--the-playerbots-fork"></a>

## Chapter 04 — Cloning AzerothCore + the Playerbots fork

### Playerbots won't build / bots never appear — you cloned the wrong repository

**Symptom:** The module fails to configure or build, or the server runs but has no bots.
You followed a guide that said to clone `liyunfan1223/azerothcore-wotlk` or plain
`azerothcore/azerothcore-wotlk`.

**Cause:** Two traps:
1. **Upstream AzerothCore does not work with Playerbots.** The module needs core hooks
   that only exist in the Playerbots fork.
2. **The project moved.** The maintained source is now under the **`mod-playerbots`**
   GitHub org, not the older `liyunfan1223` personal repositories that most tutorials
   and videos still reference.

**Fix:** Clone from the current, correct location, on the correct branches:

```
git clone https://github.com/mod-playerbots/azerothcore-wotlk.git --branch=Playerbot
cd azerothcore-wotlk/modules
git clone https://github.com/mod-playerbots/mod-playerbots.git --branch=master
```

If unsure whether these are still current, open the `mod-playerbots/mod-playerbots`
README on GitHub and use the clone commands it shows — this project relocates and
renames branches over time.

**ARM64-specific:** no

---

<a id="chapter-05--building"></a>

## Chapter 05 — Building

### The build dies with `Killed` (out of memory)

**Symptom:** The compile stops partway with something like:

```
c++: fatal error: Killed signal terminated program cc1plus
make[2]: *** [...] Error 1
```

or the process simply reports `Killed`. It often happens on the heaviest files
(Playerbots AI, or the final `worldserver` link).

**Cause:** The Pi ran out of memory. Parallel compiles (`-j4`) can briefly spike past
available RAM, and with no swap the kernel kills the compiler. Smaller Pis (8 GB, 4 GB)
hit this readily.

**Fix:** two levers, use both if needed.
1. **Add swap** (Chapter 05, Step 1) — an 8 GB swapfile is enough to absorb the spikes on
   a 16 GB Pi.
2. **Reduce parallelism** — rebuild with fewer jobs so fewer heavy files compile at once:
   ```
   make -j2      # or -j1 on a 4 GB Pi
   ```
   The build tree is preserved, so it resumes from where it stopped rather than starting
   over.

**ARM64-specific:** yes (a Raspberry Pi memory-constraint issue; the same build on a
big-RAM x86 box would not hit it)

---

<a id="chapter-07--first-boot"></a>

## Chapter 07 — First boot

### `Access denied ... 'acore_playerbots'` then `Segmentation fault (core dumped)`

**Symptom:** The world imports successfully, then:

```
Opening DatabasePool 'acore_playerbots'.
Could not connect to MySQL database at 127.0.0.1: Access denied for user 'acore'@'localhost' to database 'acore_playerbots'
DatabasePool Playerbots NOT opened.
Segmentation fault (core dumped)
```

**Cause:** Playerbots uses a **fourth database, `acore_playerbots`**, on top of the standard
three. If you created only auth/characters/world, the module can't open its database and
the server crashes.

**Fix:** Create the fourth database and grant the `acore` user access, then retry:

```
sudo mysql <<'SQL'
CREATE DATABASE IF NOT EXISTS `acore_playerbots` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `acore_playerbots` . * TO 'acore'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
```

**ARM64-specific:** no

---

### `Can't set process priority class, error: Permission denied`

**Symptom:** This line appears under the banner every start.

**Cause:** `worldserver` tries to raise its own scheduling priority and can't, because it
runs as a normal (non-root) user.

**Fix:** None needed — it's harmless. The server runs fine at normal priority. (If you make
it a systemd service later, you can grant `CAP_SYS_NICE` to silence it, but there's no
benefit for a solo realm.)

**ARM64-specific:** no

---

### The Pi bogs down with 500 bots (`Update time diff` climbing)

**Symptom:** With nobody playing, `Update time diff` mean sits at 40 ms+, and
`Random Bots Stats` shows `500 online`.

**Cause:** Playerbots' default ambient population is 500 random bots, each running AI on the
world loop. That's far too many for a 4-core Pi.

**Fix:** Lower `MinRandomBots`/`MaxRandomBots` in `playerbots.conf` (see Chapter 07, Step 3).
~40 keeps the world alive at a fraction of the load; `0` makes it silent. These are ambient
bots, separate from your personal party.

**ARM64-specific:** yes (a Pi CPU constraint; a big x86 box would shrug off 500)

---

<a id="chapter-08--the-client-side"></a>

## Chapter 08 — The client side

### The game window is trapped in the top-left corner of the screen

**Symptom:** Under Wine, `Wow.exe` launches but the logo/cinematic and login render into
only the **top-left quarter** of the monitor; you can't reach the login box.

**Cause:** The game came up **fullscreen at a small default resolution**, and Wine renders
it 1:1 into the corner instead of scaling it to your (larger, e.g. 2560×1440) display.

**Fix:** Give it a client config that forces windowed mode at a sane size. WoW only writes
`WTF/Config.wtf` on a clean exit, so if it never got that far, create the file yourself:

```
SET gxApi "d3d9"
SET gxWindow "1"
SET gxMaximize "0"
SET gxResolution "1920x1080"
SET windowResolution "1920x1080"
SET realmList "192.168.1.220"
```

`gxWindow "1"` is the key line (windowed, movable). Relaunch. After a clean run and proper
exit, the game rewrites `Config.wtf` with your monitor's real resolution/refresh — that's
expected; leave it.

**ARM64-specific:** no (a Wine/desktop issue, unrelated to the server)

---

### You've forgotten the account password

**Symptom:** Login fails and `authserver` logs `account BALIH tried to login with invalid
password!` — because you no longer remember it.

**Cause:** Recent AzerothCore (and this fork) store passwords as **SRP6 salt+verifier**,
not a plain hash, so you can't just edit the database. You reset it from the server console.

**Fix:** At a **live** `worldserver` console (the `AC>` prompt — a foreground terminal, not
an orphaned background process), set a new one:

```
account set password BALIH <newpassword> <newpassword>
```

Same value twice; it confirms "The password was changed for account BALIH." If your only
`worldserver` is orphaned (running but its `screen` shows `Dead`, so no console), stop it
with `kill <pid>` and restart it in a foreground terminal to get the prompt back. Then save
the password in a manager this time.

**ARM64-specific:** no

---

### Wine floods the terminal with `unknown message type 3` (and `winediag` fixme's)

**Symptom:** Launching `Wow.exe` fills the terminal with thousands of lines like:

```
0130:err:msg:process_hardware_message unknown message type 3
...
01c4:fixme:winediag:loader_init wine-staging 11.13 is a testing version ...
```

The game itself runs fine.

**Cause:** Both are **cosmetic**. The `winediag` line is just Wine Staging noting it's a
testing build. The `process_hardware_message unknown message type 3` flood is Wine choking
on an input event it doesn't recognise — commonly from a connected **controller / joystick
/ tablet / extra HID device**. It doesn't crash anything; it just spams stderr and wastes a
little CPU.

**Fix:** Silence Wine's debug channels with `WINEDEBUG=-all` (this is baked into the
Chapter 08 launcher script):

```
WINEPREFIX=$HOME/.wow335 WINEDEBUG=-all wine Wow.exe
```

If a game controller is plugged in and unused, unplugging it often stops the `type 3` flood
at the source — but `WINEDEBUG=-all` handles it regardless.

**ARM64-specific:** no (a Wine/desktop issue)

---

<a id="chapter-09--your-bot-party"></a>

## Chapter 09 — Your bot party

### Bot command prints a USAGE list and nothing is summoned

**Symptom:** `.playerbot addclass warrior` (or similar) does nothing but print:

```
### USAGE: .playerbots...
- playerbots account...
- playerbots bot
- ...
```

**Cause:** Wrong prefix. This fork uses **`.playerbots`** (with an **s**), and party
control is under the **`bot`** sub-word. `.playerbot` (singular) is the *old* fork's syntax
and only prints usage here.

**Fix:** Use the current form:

```
.playerbots bot addclass warrior      # class bot (dk for death knight)
.playerbots bot add Name1,Name2        # your own alt characters as bots
```

The authoritative command list is the
[mod-playerbots Playerbot Commands wiki](https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands).

**ARM64-specific:** no

---

### Bots stand still after a fight and don't catch up

**Symptom:** The party fights when you engage, then just **stays where combat ended** while
you walk off.

**Cause:** Not a bug — bots hold at the kill spot and wait for their leader's next order.

**Fix:** Tell them to regroup: in party chat, **`/p follow`**. (They auto-follow and
auto-assist by default; `/p stay` parks them, `/p attack` focus-fires your target.)

**ARM64-specific:** no

---

### A "kill X creatures" quest stops counting

**Symptom:** A kill-quest counter climbs for the first couple of kills, then stops
advancing while you keep killing the same mobs.

**Cause:** Usually one of two things — and they are **not** bugs:
1. **The quest is already done.** Open the quest log (`L`); if the objective reads `X/X`,
   it finished and simply stopped at the cap. Turn it in.
2. **A bot is stealing the tag.** In WoW you only get kill credit for a mob your group
   **tagged** (dealt first damage to) *and* that you were **near** when it died. `addclass`
   bots are fast and aggressive; if a bot tags and kills a mob while you're out of range,
   the bot gets the tag and you get no credit.

**Fix:**
- Check the quest log first — most "it stopped" reports are case 1 (already complete).
- If it's case 2: **tag the mob yourself** (one hit/spell/shot before the bots pile on), or
  `/p stay` to park the party, pull the mob, then `/p attack` so *you* stay the tagger.
- Also confirm the mobs are the **exact** creature the quest names (some zones have two
  near-identical variants; only one counts).

**ARM64-specific:** no

---

### A "collect X items" quest never advances — the drops don't exist

**Symptom:** A quest asks you to collect items from mob corpses (e.g. *Riverpaw Gnoll
Bounty*, 10 Painted Gnoll Armbands). You kill the right mobs for days — solo, in a bot
party, either way — and the item **never drops once**. Feels identical to "kills aren't
counting."

**Cause:** We hit *two* stacked causes, and the debugging order matters:

1. **A loot-touching module was eating gray quest items.** `mod-junk-to-gold` converts
   every Poor-quality item to coins at loot time — *including* gray quest objectives and
   gray quest-starter drops (its tracker knows: issue #7; the fix PR #9 was rejected by
   the maintainer). Any module that hooks loot without a quest-item exception does this.
2. **Quest items are always group-loot** — even under free-for-all. The server deals each
   quest drop to **one** eligible party member, round-robin. Bots share your quests, so
   in a 5-member bot party ~4 of every 5 drops are dealt to bots — and a drop dealt to a
   bot that never loots it despawns with the corpse. It never existed anywhere.

**Diagnosis path** (the database never lies):

```
-- is the item even supposed to drop from what you're killing?
SELECT clt.Entry, ct.name, clt.Chance, clt.QuestRequired
FROM acore_world.creature_loot_template clt
JOIN acore_world.creature_template ct ON ct.lootid = clt.Entry
WHERE clt.Item = <item_entry>;

-- does ANYONE on the realm hold the item?
SELECT c.name, COUNT(*) FROM acore_characters.item_instance ii
JOIN acore_characters.characters c ON c.guid = ii.owner_guid
WHERE ii.itemEntry = <item_entry> GROUP BY c.name;
```

If the loot table is fine but the realm-wide count is **zero**, the drops are being
destroyed or dealt-and-despawned. Confirm the group mechanic by leaving the party and
killing a few droppers solo — the items appear immediately.

**Fix:** remove the loot-eating module (see [Removing a module](optional-modules.md#removing-a-module-the-reverse-pattern)),
and install [`mod-quest-loot-party`](https://github.com/pangolp/mod-quest-loot-party) —
every party member gets their own copy of quest drops, so a bot party stops competing
with you. Both verified live on this realm, 2026-08-02. Beware: only the *exact* creatures
in the loot table drop the item — Elwynn's Riverpaw **Mongrels** share the name and drop
nothing (authentic 2004 cruelty).

**ARM64-specific:** no

---

<a id="chapter-10--keeping-it-alive"></a>

## Chapter 10 — Keeping it alive

### The journal fills with endless `AC>` lines under systemd

**Symptom:** After making `worldserver` a systemd service, `journalctl -u
azerothcore-worldserver` is flooded with:

```
worldserver[14053]: AC>
worldserver[14053]: AC>
worldserver[14053]: AC>   ...forever
```

**Cause:** `worldserver`'s interactive console reads commands from stdin. Under systemd
there's no keyboard attached (stdin is empty), so every read returns end-of-input, it
reprints the `AC>` prompt, and loops — churning the disk and burying the real log.

**Fix:** Disable the console in `worldserver.conf`; you administer the realm in-game as GM
instead:

```
sed -i -E 's/^Console\.Enable\s*=.*/Console.Enable = 0/' /mnt/nvme/azerothcore-wotlk/env/dist/etc/worldserver.conf
sudo systemctl restart azerothcore-worldserver
```

To get the real `AC>` console back for a session, `sudo systemctl stop
azerothcore-worldserver` and run `./worldserver` by hand in a terminal.

**ARM64-specific:** no

---

### MySQL won't start after moving the datadir to the NVMe

**Symptom:** After setting `datadir = /mnt/nvme/mysql`, `mysql.service` fails to start.
`dmesg` shows an AppArmor denial:

```
apparmor="DENIED" operation="open" ... name="/mnt/nvme/mysql/..." comm="mysqld"
```

**Cause:** Ubuntu's AppArmor profile (`/etc/apparmor.d/usr.sbin.mysqld`) confines `mysqld`
to `/var/lib/mysql`. A new datadir is denied *even with correct filesystem permissions*
until AppArmor is told about it. This is the one trap of a MySQL datadir move on Ubuntu.

**Fix:** Add the new path to the profile's local override (which the vendor profile already
includes) and reload it — mirroring the existing `/var/lib/mysql` rules:

```
sudo tee -a /etc/apparmor.d/local/usr.sbin.mysqld > /dev/null <<'EOF'
/mnt/nvme/mysql/ r,
/mnt/nvme/mysql/** rwk,
EOF
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
sudo systemctl start mysql
```

Rollback if needed is trivial: point the datadir back at `/var/lib/mysql` (remove
`zz-datadir.cnf`) and restart — the original copy is kept as `/var/lib/mysql.bak` until
you've confirmed the move.

**ARM64-specific:** no

---

## Hit something we did not?

Open an issue with the chapter number, the command you ran, and the **complete** error output. If you already solved it, say so and it gets added here with credit to you.
