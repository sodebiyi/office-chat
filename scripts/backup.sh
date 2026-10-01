#!/usr/bin/env bash
# Nightly backup: Postgres dump plus an archive of the Mattermost data volumes.
# Usage: ./scripts/backup.sh [mattermost-docker-dir] [backup-dir]
set -euo pipefail

TARGET_DIR="${1:-mattermost-docker}"
BACKUP_DIR="${2:-$HOME/mattermost-backups}"
KEEP_DAYS=14
DB_USER="mmuser"
DB_NAME="mattermost"

mkdir -p "$BACKUP_DIR"
cd "$TARGET_DIR"

STAMP="$(date +%F)"

docker compose exec -T postgres pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/db-$STAMP.sql"
tar -czf "$BACKUP_DIR/data-$STAMP.tar.gz" ./volumes/app/mattermost/data ./volumes/app/mattermost/config

find "$BACKUP_DIR" -type f \( -name 'db-*.sql' -o -name 'data-*.tar.gz' \) -mtime +"$KEEP_DAYS" -delete

echo "Backup written to $BACKUP_DIR ($STAMP)"
echo "Copy this folder to a second disk or external drive as well."
