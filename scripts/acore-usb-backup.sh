#!/usr/bin/env bash
#
# acore-usb-backup.sh - copy the realm's database backups to a USB drive, safely.
#
# Part of the pi-kognog-azerothcore guide (optional off-box backups). Runs on the
# PI. Mounts the stick, copies every dump from the NVMe backup folder, syncs,
# unmounts, and only then says "SAFE TO UNPLUG".
#
# Usage:  sudo acore-usb-backup.sh [device]     (default: /dev/sda1)
# Identify the stick first with:  lsblk -o NAME,SIZE,FSTYPE,LABEL,VENDOR,MODEL
#
set -euo pipefail

DEVICE="${1:-/dev/sda1}"
SOURCE_DIR="/mnt/nvme/backups/mysql"
MOUNT_POINT="/mnt/usb-backup"
DEST_NAME="tpgaming01-mysql"

# Refuse the system disks outright - only ever touch a USB device.
case "$DEVICE" in
    /dev/mmcblk0*|/dev/nvme*)
        echo "error: $DEVICE is a system disk. Refusing." >&2; exit 1 ;;
esac
[[ -b "$DEVICE" ]] || { echo "error: $DEVICE is not a block device (is the stick plugged in?)" >&2; exit 1; }
findmnt -n "$DEVICE" > /dev/null && { echo "error: $DEVICE is already mounted. Unmount it first." >&2; exit 1; }

mkdir -p "$MOUNT_POINT"
mount "$DEVICE" "$MOUNT_POINT"
trap 'umount "$MOUNT_POINT" 2>/dev/null || true' EXIT

mkdir -p "$MOUNT_POINT/$DEST_NAME"
rsync -rtvh --modify-window=2 "$SOURCE_DIR"/ "$MOUNT_POINT/$DEST_NAME"/

sync
umount "$MOUNT_POINT"
trap - EXIT
echo
echo "Done. Drive unmounted - SAFE TO UNPLUG."
