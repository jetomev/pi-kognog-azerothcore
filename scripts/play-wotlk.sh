#!/usr/bin/env bash
#
# play-wotlk.sh — launch WoW 3.3.5a (AzerothCore + Playerbots) under Wine on Linux.
#
# Part of the pi-kognog-azerothcore guide. One command runs the client with all the
# right conditions baked in: the dedicated Wine prefix, silenced Wine logging, gamemode
# if it's installed, launched from the client folder.
#
# Setup:
#   1. Edit the three variables below to match your machine.
#   2. Make it executable:   chmod +x play-wotlk.sh
#   3. Run it:               ./play-wotlk.sh
#
set -euo pipefail

# ---- Edit these to match your setup --------------------------------
GAME_DIR="$HOME/Games/ChromieCraft_3.3.5a"   # folder that contains Wow.exe
WINEPREFIX_DIR="$HOME/.wow335"               # the dedicated Wine prefix (Chapter 08)
WOW_EXE="Wow.exe"
# --------------------------------------------------------------------

# Fail early with a clear message rather than a cryptic Wine error.
if ! command -v wine >/dev/null 2>&1; then
    echo "error: 'wine' is not installed or not on PATH." >&2
    exit 1
fi
if [[ ! -f "$GAME_DIR/$WOW_EXE" ]]; then
    echo "error: '$GAME_DIR/$WOW_EXE' not found — fix GAME_DIR at the top of this script." >&2
    exit 1
fi

export WINEPREFIX="$WINEPREFIX_DIR"
export WINEDEBUG=-all      # silence Wine's cosmetic fixme/err spam (e.g. "unknown message type 3")

cd "$GAME_DIR"

# gamemoderun tunes the CPU governor while the game runs; harmless if you didn't install it.
if command -v gamemoderun >/dev/null 2>&1; then
    exec gamemoderun wine "$WOW_EXE"
else
    exec wine "$WOW_EXE"
fi
