# Chapter 01 — The client and extracting game data

AzerothCore does not ship the game's maps, models, or navigation data — it cannot,
that content belongs to Blizzard. Instead, you **extract** it from a 3.3.5a client you
already own, using small tools built from the AzerothCore source. This chapter produces
four folders — `dbc`, `maps`, `vmaps`, `mmaps` — that the server needs to run.

> **We do this on the desktop, not the Pi.** Extraction, and especially the navigation
> mesh (`mmaps`) step, is CPU-heavy. On a fast desktop it is minutes; on a Pi it would
> be many hours. The extracted data is portable, so we build it once on the desktop and
> copy it to the Pi later. **Wiping the Pi never re-costs this step.**

## What this is

Three things happen here:

1. **Verify the client** is genuinely 3.3.5a build 12340. Everything downstream depends
   on it.
2. **Build the extractor tools** from the AzerothCore source (four small binaries).
3. **Run them** against the client to produce `dbc`, `maps`, `vmaps`, `mmaps`.

## Why it matters

The server loads this data at startup. `maps` and `vmaps` are the world geometry and
line-of-sight collision; `mmaps` are the navigation meshes that let creatures — and
**Playerbots** — path through the world. No `mmaps`, no bot movement. Getting this
right once, from a correct client, saves you from a class of "why won't my bot move"
problems later.

## Before you start

- A **3.3.5a build 12340** client. This guide used the one from ChromieCraft. Sourcing
  it is your responsibility; we do not link or distribute it.
- A Linux desktop to extract on. See the reference machine below.
- ~25 GB free for the extracted client, plus a few GB for the output data.

### Reference machine (so the timings mean something)

Every duration in this chapter came from this desktop. Yours will differ; a slower or
older machine can be **much** slower, especially at the `mmaps` step — that is the whole
reason we do not extract on the Pi.

| Component | This guide's extraction desktop |
|---|---|
| CPU | AMD Ryzen 7 7700 (8 cores / 16 threads) |
| RAM | 32 GB |
| Storage | 1 TB SATA SSD |
| OS | Arch Linux, kernel 7.0.5-zen, x86_64 |
| Toolchain | GCC 16.1, CMake 4.4.0, Boost 1.91.0, mariadb-libs 12.3.2 |

A note on that toolchain: it is **bleeding-edge** (GCC 16, CMake 4). That newness caused
exactly one build failure, which we fixed with a single flag — see Step 2 and
Troubleshooting. On a more conventional distro (Ubuntu/Debian stable) you may not hit it
at all.

---

## Steps

### 1. Verify the client

Unzip your client somewhere permanent — it is both the extraction source now and your
Wine play-client in Chapter 08. This guide keeps it at `~/Games/ChromieCraft_3.3.5a`.

Confirm it is the right build. The 3.3.5a enUS `Wow.exe` has a known MD5:

```
desktop $ md5sum ~/Games/ChromieCraft_3.3.5a/Wow.exe
# expected: 45892bdedd0ad70aed4ccd22d9fb5984
```

If your hash matches, you have the correct client and can stop worrying about it. (The
extractors will also print `Detected client build: 12340` when they run, a second
confirmation.) Check that `Data/` holds the MPQ archives — you should see `common.MPQ`,
`expansion.MPQ`, `lichking.MPQ`, `patch*.MPQ`, and an `enUS/` subfolder.

### 2. Build the extractor tools

Install the build dependencies (Arch package names shown; adjust for your distro):

```
desktop $ sudo pacman -S --needed cmake boost mariadb-libs
```

- `cmake`, `boost` — the build system and libraries AzerothCore uses.
- `mariadb-libs` — the MySQL/MariaDB **client** library. You are not running a database
  on the desktop; this is only here because AzerothCore's CMake configures its `server`
  directory unconditionally, and that step checks for MySQL headers even when you are
  building only the tools. Without it you get `MYSQL_INCLUDE_DIR-NOTFOUND`.

Clone the AzerothCore source (shallow is fine — we only need it to build the tools):

```
desktop $ git clone --depth 1 https://github.com/azerothcore/azerothcore-wotlk.git ~/azerothcore-tools
```

Configure a **tools-only** build. Two flags matter and are not obvious:

```
desktop $ cd ~/azerothcore-tools && mkdir -p build && cd build
desktop $ cmake .. \
    -DCMAKE_INSTALL_PREFIX=$HOME/azerothcore-tools/install \
    -DTOOLS_BUILD=all -DSCRIPTS=none -DNOJEM=1 \
    -DCMAKE_BUILD_TYPE=Release
```

- **`-DTOOLS_BUILD=all`** builds the extractors. Note it is `TOOLS_BUILD`, a string —
  **not** `-DTOOLS=1`, which AzerothCore silently ignores.
- **`-DNOJEM=1`** disables jemalloc, a bundled memory allocator. AzerothCore vendors an
  old copy of it that does not compile on very new compilers (GCC 16 here). The
  extractors do not need it. If you are on an older, stable toolchain you can omit this
  flag; on bleeding-edge, it is what stops the build dying on
  `'__throw_bad_alloc' is not a member of 'std'`.

Compile just the four extractors (not the whole server):

```
desktop $ make -j$(nproc) map_extractor vmap4_extractor vmap4_assembler mmaps_generator
```

The binaries land in `~/azerothcore-tools/build/src/tools/`.

### 3. Set up a clean extraction workspace

The extractors read `Data/` from their working directory and write output alongside it.
Rather than clutter your client folder, make a workspace whose `Data/` is a **symlink**
to the client (no multi-GB copy), with the tools beside it:

```
desktop $ mkdir -p ~/azeroth-extract && cd ~/azeroth-extract
desktop $ ln -sfn ~/Games/ChromieCraft_3.3.5a/Data Data
desktop $ cp ~/azerothcore-tools/build/src/tools/{map_extractor,vmap4_extractor,vmap4_assembler,mmaps_generator} .
```

### 4. Extract, in order

Each tool depends on the previous one's output. Run them from `~/azeroth-extract`.

**a. Maps, DBC, cameras** (`map_extractor`, no arguments = extract everything):

```
desktop $ ./map_extractor
```
Produces `dbc/`, `maps/`, `Cameras/`. Prints `Detected client build: 12340`.
*Reference time: under 1 minute.*

**b. Raw building/model data** (`vmap4_extractor`):

```
desktop $ ./vmap4_extractor
```
Produces `Buildings/` (an intermediate). Ends with `Work complete. No errors.`
*Reference time: a few minutes.*

**c. Assemble vmaps** (`vmap4_assembler <raw dir> <dest dir>`):

```
desktop $ mkdir -p vmaps && ./vmap4_assembler Buildings vmaps
```
Produces `vmaps/`. Ends with `Ok, all done`. `Buildings/` can be deleted afterward.
*Reference time: under 1 minute.*

**d. Navigation meshes** (`mmaps_generator`) — the long one:

```
desktop $ cp ~/azerothcore-tools/src/tools/mmaps_generator/mmaps-config.yaml .
desktop $ mkdir -p mmaps && ./mmaps_generator --threads $(( $(nproc) - 1 ))
```
- This version **requires `mmaps-config.yaml`** in the working directory, or it aborts.
- `--threads` defaults to all cores; we leave one free for the desktop to stay usable.
- Produces `mmaps/` (thousands of `.mmtile` files). Ends with
  `Finished. MMAPS were built in N minute(s)`.

*Reference time: **8 minutes 36 seconds** on the Ryzen 7700 with 15 threads. On a slower
machine this can be hours — plan accordingly, and be glad you are not doing it on the Pi.*

---

## Results

On the reference machine, the complete server-side dataset:

| Folder | Contents | Size |
|---|---|---|
| `dbc/` | client database tables (246 files) | 87 MB |
| `maps/` | world height/terrain (135 maps) | 295 MB |
| `vmaps/` | line-of-sight / collision geometry | 657 MB |
| `mmaps/` | navigation meshes (3,682 tiles) | 2.1 GB |
| `Cameras/` | cinematic camera paths | 56 KB |
| **Total** | | **~3.1 GB** |

**This is the number that matters for the Pi.** Tutorials often quote 60–80 GB for a WoW
setup — but that is the *client* plus its optional HD visual/audio mods, which live on
your desktop. The **server** only ever holds this ~3 GB of extracted data (plus the build
and databases in later chapters). A 128 GB disk on the Pi is comfortably oversized for it.

The `dbc`, `maps`, `vmaps`, and `mmaps` folders are what get copied to the Pi when we set
the server up. Keep them; they do not need to be regenerated unless you change clients.

## ✅ Checkpoint

You are done with Chapter 01 when:

- `md5sum Wow.exe` matched `45892bdedd0ad70aed4ccd22d9fb5984`.
- All four tools built without error.
- `~/azeroth-extract/` contains `dbc/`, `maps/`, `vmaps/`, and `mmaps/`, and
  `mmaps_generator` reported `Finished`.

## ⚠ If it went wrong

The failures we actually hit are in [TROUBLESHOOTING.md](TROUBLESHOOTING.md):

- **`'__throw_bad_alloc' is not a member of 'std'`** building jemalloc — new-compiler
  breakage, fixed with `-DNOJEM=1`.
- **`MYSQL_INCLUDE_DIR-NOTFOUND`** configuring a tools-only build — install the MariaDB
  client library.
- **`-DTOOLS=1` ignored / it builds the whole server** — the flag is `-DTOOLS_BUILD=all`.
- **`mmaps_generator` aborts on missing `mmaps-config.yaml`** — copy it from the source
  into the working directory.
