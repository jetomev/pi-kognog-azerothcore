# Chapter 08 — The client side

The realm runs, but nothing can reach it yet. This chapter makes the server reachable on
your network, starts the login server, and connects a **Linux** client to it — bare
**Wine**, no Windows anywhere. By the end you are standing in Azeroth, logged in with the
account you made in Chapter 07.

> This chapter has **two halves**. The first runs **on the Pi** (`tpgaming01 $`) to make
> the realm reachable. The second runs **on your desktop** (`desktop $`) to connect the
> client. Watch the marker on each command.
>
> Connect to the Pi first:
> ```
> ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
> ```

## What this is

Two servers have to be running for anyone to log in, and the realm has to advertise an
address the client can actually reach:

- **`authserver`** — the login gatekeeper (port **3724**). Checks your account and
  password, then hands you a list of realms.
- **`worldserver`** — the world itself (port **8085**). Everything after login.
- **`realmlist`** — a row in the `acore_auth` database telling clients *where the world
  is*. Out of the box it says `127.0.0.1` (localhost), which only works if you play on the
  Pi itself. From another machine, that has to be the Pi's LAN address.

On the client side, a 3.3.5a client is a Windows program, so on Linux it runs through a
compatibility layer. This guide's main path is **bare Wine** — no launcher suite required.

## Why it matters

This is where the whole chain is proven end to end: desktop → Wine → LAN → `authserver` →
`worldserver`. Three things silently block it if they're wrong — the realm address, the
firewall, and having *both* servers up — so we do them in that order and check each.

## Before you start

- Chapter 07 complete: a booting `worldserver` and a GM account (we use `BALIH`).
- A **3.3.5a (build 12340)** client on your desktop. Sourcing it is yours to handle; we do
  not link or distribute it. *(Reference client folder here:
  `/home/jetomev/Games/ChromieCraft_3.3.5a/`.)*
- On the desktop: **Wine** installed (reference: `wine-11.13` Staging on Arch) and
  `gamemode` (optional, for tier 2).

---

## Part A — make the realm reachable (on the Pi)

### 1. Point the realm at the Pi's address

Read what's set now:

```
tpgaming01 $ sudo mysql -e "SELECT id, name, address, localAddress, port FROM acore_auth.realmlist;"
```

You'll almost certainly see `address = 127.0.0.1`. Change it to the Pi's LAN IP:

```
tpgaming01 $ sudo mysql -e "UPDATE acore_auth.realmlist SET address = '192.168.1.220' WHERE id = 1;"
```

Leave `localAddress` at `127.0.0.1`. AzerothCore hands a client `localAddress` only when
that client shares the realm's local subnet (`localSubnetMask`, default `255.255.255.0`);
a desktop at `192.168.1.x` doesn't match `127.0.0.x`, so it correctly receives the real
`address`. Leaving `localAddress` alone keeps the "play on the Pi itself" case working too.

### 2. Open the two game ports (to your LAN only)

Chapter 00 locked `ufw` down to SSH. The client needs two more doors — scoped to the LAN,
never the whole internet:

```
tpgaming01 $ sudo ufw allow from 192.168.1.0/24 to any port 3724 proto tcp
tpgaming01 $ sudo ufw allow from 192.168.1.0/24 to any port 8085 proto tcp
tpgaming01 $ sudo ufw status numbered
```

If these are shut, login fails with no useful error — you type your password and hit a
wall. `3724` is `authserver`, `8085` is `worldserver` (the `port` from the realmlist row).

### 3. Run **both** servers

`worldserver` from Chapter 07 is only half of it. Start `authserver` too. Simplest is a
foreground terminal each, so you can watch both:

```
tpgaming01 $ cd /mnt/nvme/azerothcore-wotlk/env/dist/bin
tpgaming01 $ ./authserver
```

`authserver` is healthy when it connects to `acore_auth`, updates, and prints:

```
Added realm "AzerothCore" at 192.168.1.220:8085.
```

That address is your Step 1 change taking effect. Confirm both ports are listening (from a
second Pi shell):

```
tpgaming01 $ ss -tlnp | grep -E ':3724|:8085'
```

You want a `LISTEN` line for **each** port.

> **A note on `screen`.** You can run the servers under `screen` so they survive a dropped
> SSH session, but its split-visuals annoy some people. Plain foreground terminals are
> fine for this chapter — you get the live console and can watch login attempts land. Just
> don't close the terminal, or you kill the server in it. A note on **orphaned** servers:
> if a `screen` session dies but its `worldserver` keeps running, you get a live process
> with **no console you can attach to** (`screen -ls` shows it `Dead`). You can't type
> commands into it. Stop it cleanly with `kill <pid>` (SIGTERM; AzerothCore traps it and
> shuts down gracefully) and restart it in a terminal you control.

---

## Part B — connect the Linux client (on the desktop)

### 4. Point the client at the Pi

Edit the client's realm file — for an `enUS` client it's at
`<client>/Data/enUS/realmlist.wtf` (substitute your locale). Its **entire** contents:

```
set realmlist 192.168.1.220
```

One line, the Pi's address, nothing else. Delete any old retail address.

> **The launcher trap:** if your client has a `Launcher.exe`, do **not** run it — launchers
> rewrite `realmlist.wtf` back to Blizzard's servers every time. Run `Wow.exe` directly. A
> clean private-server client folder (like the reference one) has only `Wow.exe`, so this
> doesn't arise.

### 5. Run it — bare Wine, in a dedicated prefix

We isolate the game in its own `WINEPREFIX` so we never touch your default `~/.wine`, and
so it's disposable (`rm -rf ~/.wow335` to start clean):

```
desktop $ export WINEPREFIX=$HOME/.wow335
desktop $ export WINEARCH=win64
desktop $ wineboot -u
desktop $ cd /home/jetomev/Games/ChromieCraft_3.3.5a/
desktop $ wine Wow.exe
```

- `wineboot -u` initializes the prefix. If it offers to install **Mono** or **Gecko**,
  click **No** on both — WoW needs neither.
- 3.3.5a is a 16-year-old game; bare Wine runs it well. **This is the guide's main path** —
  no Lutris, no Steam. Those are Optionals (Step 8).

### 6. Fix the window if it lands in a corner

A common first-launch symptom: the game opens **fullscreen at a small resolution** and
Wine renders it 1:1 into the **top-left of your monitor**, unreachable. The fix is a client
config that forces a sane windowed size. WoW writes `WTF/Config.wtf` only on a clean exit,
so if it never got that far, create the file yourself:

```
SET gxApi "d3d9"
SET gxWindow "1"
SET gxMaximize "0"
SET gxResolution "1920x1080"
SET windowResolution "1920x1080"
SET gxRefresh "60"
SET gxColorBits "24"
SET gxDepthBits "24"
SET realmList "192.168.1.220"
```

- `gxWindow "1"` — windowed mode: a normal, movable window that fits inside your screen.
- `gxApi "d3d9"` — the DirectX 9 path (and what DXVK hooks into in tier 2). **Not**
  `opengl`, which bypasses DXVK.

Relaunch (Step 5). Once it runs cleanly and you exit properly, the game **rewrites**
`Config.wtf` with your monitor's real settings (higher resolution, refresh, MSAA) — that's
expected, and a sign it's happy. Leave it be.

### 7. Log in and walk in

At the login screen, use the Chapter 07 account:

- **Account:** `BALIH`
- **Password:** the one you set (see the troubleshooting entry below if you've forgotten it)

Watch the Pi's `authserver` terminal as you press Enter. A **wrong** password logs:

```
'<your-ip>' [AuthChallenge] account BALIH tried to login with invalid password!
```

A **correct** one logs *nothing* — success is silent; you're handed to `worldserver` and
the realm list appears. Enter the realm, create a character, and step into the world.

### 8. One command to launch it all

Once it works, you don't want to retype the prefix, the debug flag, and the `cd` every
time. Wrap it in a small launcher so the whole thing is a single command. The guide ships
a template at [`scripts/play-wotlk.sh`](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/scripts/play-wotlk.sh):

```bash
#!/usr/bin/env bash
set -euo pipefail

# ---- Edit these to match your setup ----
GAME_DIR="$HOME/Games/ChromieCraft_3.3.5a"   # folder that contains Wow.exe
WINEPREFIX_DIR="$HOME/.wow335"               # the dedicated Wine prefix
WOW_EXE="Wow.exe"
# ----------------------------------------

export WINEPREFIX="$WINEPREFIX_DIR"
export WINEDEBUG=-all      # silence Wine's cosmetic fixme/err spam

cd "$GAME_DIR"
if command -v gamemoderun >/dev/null 2>&1; then
    exec gamemoderun wine "$WOW_EXE"
else
    exec wine "$WOW_EXE"
fi
```

What it bakes in, so a reader never has to remember it:
- the **dedicated prefix** (`WINEPREFIX=~/.wow335`),
- **`WINEDEBUG=-all`**, which silences Wine's harmless-but-noisy console spam (the endless
  `err:msg:process_hardware_message unknown message type 3` lines and the `winediag`
  fixme's — cosmetic, see Troubleshooting),
- **`gamemoderun`** automatically, *if* it's installed (skipped cleanly if not),
- launching from the **client folder**.

The tidiest place for it is **inside the client folder, next to `Wow.exe`**, so everything
lives in one directory:

```
desktop $ cp scripts/play-wotlk.sh ~/Games/ChromieCraft_3.3.5a/play-wotlk.sh
desktop $ chmod +x ~/Games/ChromieCraft_3.3.5a/play-wotlk.sh
desktop $ ~/Games/ChromieCraft_3.3.5a/play-wotlk.sh
```

That single command is now "play the game" (the script's `GAME_DIR` default already points
at this folder, so it runs from anywhere). For a **double-click** launcher, adapt
[`scripts/wotlk.desktop`](https://github.com/jetomev/pi-kognog-azerothcore/blob/main/scripts/wotlk.desktop) — set its `Exec=` line to the absolute
path of your `play-wotlk.sh` (e.g. the one you just copied into the client folder). Keep it
beside the script, or copy it to `~/.local/share/applications/` to get it in your app menu.
Some file managers ask you to mark a `.desktop` file "trusted" / "Allow launching" the
first time.

### 9. (Optional) Lutris and Steam/Proton

Bare Wine is the main path because it's the fewest moving parts and it works. The other two
runners are documented in **[optional-modules.md](optional-modules.md)** for people who
prefer a managed setup:

- **Lutris** — a friendlier front-end over Wine, with community install scripts and
  per-game prefixes. A known-good way to run 3.3.5a; no advantage in raw performance over a
  hand-made prefix (3.3.5a doesn't use Vulkan natively), but tidier to manage.
- **Steam + Proton** — runs the client as a "non-Steam game" under Proton. Viable if Steam
  is already your hub.

**Tier 2 — DXVK (still bare Wine, recommended for polish):** DXVK translates the game's
DirectX 9 to Vulkan and is just a set of DLLs dropped into the prefix. Keep `gxApi "d3d9"`,
install DXVK into `~/.wow335`, and launch with `gamemoderun wine Wow.exe`. This is where
the smoothest performance lives, and it stays "Wine only" — no launcher required.

## ✅ Checkpoint

Chapter 08 is done when:

- `authserver` prints `Added realm "AzerothCore" at 192.168.1.220:8085` and both `3724`
  and `8085` are `LISTEN`ing,
- the client reaches a full login screen through bare Wine,
- logging in as `BALIH` succeeds (the wrong-password line stops appearing), and
- you can create a character, enter the world, **move, fight, loot** — proof the maps and
  the v19 mmaps are correct client-side too.

Next chapter: summon your bot party.

## ⚠ If it went wrong

- **Login hangs / "unable to connect"** — usually the firewall (Step 2) or `authserver`
  not running (Step 3). Confirm both ports `LISTEN` and that `realmlist.address` is the
  Pi's LAN IP, not `127.0.0.1`.
- **Game window trapped in the top-left corner** — resolution/window-mode; write
  `Config.wtf` with `gxWindow "1"` (Step 6).
- **"tried to login with invalid password"** — wrong password (or you've forgotten it);
  reset it from the server console (Troubleshooting, Chapter 08).
- **Wine won't launch `Wow.exe`** — see Troubleshooting; if bare Wine truly won't
  cooperate on your distro, fall back to Lutris (Step 8), which you know works.
