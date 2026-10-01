#!/usr/bin/env bash
# Installs Tailscale and serves Mattermost (port 8065) over HTTPS on your private network.
# Uses "serve", not "funnel": nothing is exposed to the public internet.
set -euo pipefail

if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "Opening Tailscale login. Follow the link to add this server to your organization."
sudo tailscale up

sudo tailscale serve --bg 8065

echo
echo "Done. Your private HTTPS address is shown below:"
sudo tailscale serve status
echo
echo "Share that .ts.net address with staff, and set it as the Site URL in System Console."
