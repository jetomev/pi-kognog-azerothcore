# Troubleshooting

Every problem we actually hit, with the exact error text and what fixed it. Entries are added **as they happen**, not remembered afterwards.

Search this file by the error message. That is how you will arrive here.

**Jump to a chapter:**
[00 — Provisioning](#chapter-00--provisioning-the-pi) ·
[01 — Client & game data](#chapter-01--the-client-and-extracting-game-data)

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

## Hit something we did not?

Open an issue with the chapter number, the command you ran, and the **complete** error output. If you already solved it, say so and it gets added here with credit to you.
