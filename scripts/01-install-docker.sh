#!/usr/bin/env bash
# Installs Docker on Ubuntu using Docker's official convenience script.
set -euo pipefail

if command -v docker >/dev/null 2>&1; then
  echo "Docker is already installed: $(docker --version)"
else
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
fi

sudo usermod -aG docker "$USER"

echo
echo "Done. Log out and back in so you can run docker without sudo, then check:"
echo "  docker --version"
echo "  docker compose version"
