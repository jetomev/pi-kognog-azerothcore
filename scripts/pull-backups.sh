#!/usr/bin/env bash
#
# pull-backups.sh — copy the realm's database backups OFF the Pi, onto this machine.
#
# Part of the pi-kognog-azerothcore guide (optional off-box backups). Runs on your
# DESKTOP, not the Pi. Pulls every dump from the Pi's backup folder over SSH/rsync.
# Run it whenever you want a safety copy — and ALWAYS before wiping, reinstalling,
# or experimenting on the Pi.
#
# Setup:
#   1. Edit the variables below to match your machine.
#   2. chmod +x pull-backups.sh
#   3. ./pull-backups.sh    (you'll be asked for your SSH key passphrase)
#
set -euo pipefail

# ---- Edit these to match your setup --------------------------------
PI_HOST="tphome@192.168.1.220"                # user@address of the Pi
SSH_KEY="$HOME/.ssh/id_ed25519_tpgaming"      # your private key for the Pi
REMOTE_DIR="/mnt/nvme/backups/mysql/"         # the Pi's backup folder
LOCAL_DIR="$HOME/Backups/tpgaming01-mysql"    # where copies land on this machine
# --------------------------------------------------------------------

if ! command -v rsync >/dev/null 2>&1; then
    echo "error: rsync is not installed on this machine." >&2
    exit 1
fi

mkdir -p "$LOCAL_DIR"

# No --delete: copies pruned on the Pi are KEPT here. This machine is the archive.
rsync -avh -e "ssh -i $SSH_KEY" "$PI_HOST:$REMOTE_DIR" "$LOCAL_DIR/"

echo
echo "Off-box copy complete. Newest files in $LOCAL_DIR:"
ls -lht "$LOCAL_DIR" | head -6
