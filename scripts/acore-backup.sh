#!/usr/bin/env bash
#
# acore-backup.sh — dump all four AzerothCore databases, gzipped and timestamped,
# pruning copies older than RETENTION_DAYS.
#
# Runs as root and authenticates to MySQL through the local socket (auth_socket),
# so no password is ever stored on disk. Install as /usr/local/bin/acore-backup.sh
# and drive it with the acore-backup.service + .timer units.
#
set -euo pipefail

BACKUP_DIR="/mnt/nvme/backups/mysql"
RETENTION_DAYS=14
DBS=(acore_auth acore_characters acore_world acore_playerbots)

mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"

for db in "${DBS[@]}"; do
    mysqldump --single-transaction --quick --routines --triggers "$db" \
        | gzip > "$BACKUP_DIR/${db}-${STAMP}.sql.gz"
done

find "$BACKUP_DIR" -name '*.sql.gz' -type f -mtime +"$RETENTION_DAYS" -delete
