#!/usr/bin/env bash
#
# acore-backup.sh — dump all four AzerothCore databases, gzipped and timestamped,
# to the NVMe (7-day retention), plus a second copy of the three IRREPLACEABLE
# databases to the microSD (3-day retention). acore_world is static, regenerable
# game data, so it stays off the card to spare its write endurance.
#
# Runs as root and authenticates to MySQL through the local socket (auth_socket),
# so no password is ever stored on disk. Install as /usr/local/bin/acore-backup.sh
# and drive it with the acore-backup.service + .timer units.
#
set -euo pipefail

# Primary backups (NVMe) - all four databases
BACKUP_DIR="/mnt/nvme/backups/mysql"
RETENTION_DAYS=7
DBS=(acore_auth acore_characters acore_world acore_playerbots)

# Second copy (microSD, root filesystem) - only the irreplaceable databases
SD_BACKUP_DIR="/var/backups/acore-mysql"
SD_RETENTION_DAYS=3
DYNAMIC_DBS=(acore_auth acore_characters acore_playerbots)

mkdir -p "$BACKUP_DIR" "$SD_BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "AzerothCore backup ${STAMP}"
echo "Primary copy (NVMe, ${RETENTION_DAYS}-day retention):"
for db in "${DBS[@]}"; do
    out="$BACKUP_DIR/${db}-${STAMP}.sql.gz"
    mysqldump --single-transaction --quick --routines --triggers "$db" \
        | gzip > "$out"
    echo "  $db -> $out ($(du -h "$out" | cut -f1))"
done

echo "Second copy (microSD, ${SD_RETENTION_DAYS}-day retention):"
for db in "${DYNAMIC_DBS[@]}"; do
    cp "$BACKUP_DIR/${db}-${STAMP}.sql.gz" "$SD_BACKUP_DIR/"
    echo "  ${db}-${STAMP}.sql.gz -> $SD_BACKUP_DIR/"
done

find "$BACKUP_DIR" -name '*.sql.gz' -type f -mtime +"$RETENTION_DAYS" -delete
find "$SD_BACKUP_DIR" -name '*.sql.gz' -type f -mtime +"$SD_RETENTION_DAYS" -delete
echo "Backup complete."
