#!/usr/bin/env bash
# Pulls newer images and restarts Mattermost.
# Bump MATTERMOST_IMAGE_TAG in .env to a newer pinned version first, and run backup.sh.
set -euo pipefail

TARGET_DIR="${1:-mattermost-docker}"
cd "$TARGET_DIR"

docker compose pull
docker compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d

echo "Updated. Check System Console > Server Logs for errors."
