#!/usr/bin/env bash
# Clones Mattermost's official Docker setup, creates .env, and prepares data directories.
set -euo pipefail

TARGET_DIR="${1:-mattermost-docker}"

if [ ! -d "$TARGET_DIR" ]; then
  git clone https://github.com/mattermost/docker "$TARGET_DIR"
fi

cd "$TARGET_DIR"

if [ ! -f .env ]; then
  cp env.example .env
  echo "Created .env from env.example"
fi

mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}
sudo chown -R 2000:2000 ./volumes/app/mattermost

echo
echo "Next, edit $TARGET_DIR/.env and set:"
echo "  DOMAIN               your server's local IP or hostname (add the Tailscale name later)"
echo "  MATTERMOST_IMAGE_TAG a pinned version such as release-10.5, not latest"
echo "  database password    a strong password, saved in a password manager"
echo
echo "Then run ./scripts/03-start-mattermost.sh"
