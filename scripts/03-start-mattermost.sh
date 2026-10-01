#!/usr/bin/env bash
# Starts Mattermost without the bundled nginx layer (Tailscale Serve provides HTTPS).
set -euo pipefail

TARGET_DIR="${1:-mattermost-docker}"
cd "$TARGET_DIR"

if grep -qiE '^(POSTGRES_PASSWORD|MM_POSTGRES_PASSWORD)=.*(mmuser_password|changeme|password)' .env 2>/dev/null; then
  echo "Warning: .env still looks like it has a sample database password. Change it before first start."
  read -r -p "Continue anyway? [y/N] " answer
  [ "${answer:-N}" = "y" ] || exit 1
fi

docker compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d

echo
echo "Mattermost is starting. Open http://<server-ip>:8065 from the office network."
echo "The first account you create becomes the System Admin."
