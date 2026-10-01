# Office Chat: Self-Hosted Team Messaging on a Spare PC

A step-by-step setup for running a private, Slack-style chat workspace for a small team (5 to 20 people) on hardware you already own. It uses Mattermost for the chat itself and Tailscale so staff can reach it from home or on their phones without opening any ports on your router.

This repository contains the written guide plus a few small scripts that automate the repetitive parts: installing Docker, preparing and starting Mattermost, setting up Tailscale, and running backups and updates.

## What you end up with

- Channels, direct messages, file sharing, search and mentions
- Desktop and mobile apps for every employee
- Everything stored on your own office machine
- Remote access over an encrypted private network, with no public IP and no port forwarding
- No per-user fee for the features a small team needs

## Why not build a chat app from scratch

A custom chat app means owning real-time messaging, authentication, storage and every security patch indefinitely. Mattermost already does all of that, is free and open source for this use, and runs as a Docker container, so you can be chatting the same afternoon.

## Requirements

- A spare PC with 2 or more CPU cores, 4 GB RAM and 20 GB or more of free disk
- Ubuntu Server LTS (recommended). Windows with WSL2 and Docker Desktop also works, see the guide
- A fixed local IP for that PC (a DHCP reservation on your router is enough)
- A free Tailscale account (free for small teams, up to 100 devices)

## Quick start

On the Ubuntu server:

```bash
git clone https://github.com/sodebiyi/office-chat.git
cd office-chat

./scripts/01-install-docker.sh        # then log out and back in
./scripts/02-prepare-mattermost.sh    # clones Mattermost's official Docker setup and creates .env
# edit mattermost-docker/.env: set DOMAIN, pin MATTERMOST_IMAGE_TAG, change the database password
./scripts/03-start-mattermost.sh      # brings the server up on port 8065
./scripts/04-setup-tailscale.sh       # private remote access with HTTPS
```

Then open `http://<server-ip>:8065` from the office network, create the first account (it becomes the System Admin), and follow the rest of the guide.

## Documentation

The full walkthrough is in [docs/setup-guide.md](docs/setup-guide.md). It covers:

1. The plan in short
2. Preparing the spare PC
3. Installing Docker
4. Deploying Mattermost
5. First login and inviting the team
6. Remote access with Tailscale
7. Backups and updates
8. Launch checklist (also in [docs/launch-checklist.md](docs/launch-checklist.md))

## Scripts

| Script | What it does |
| --- | --- |
| `scripts/01-install-docker.sh` | Installs Docker using the official script and adds your user to the docker group |
| `scripts/02-prepare-mattermost.sh` | Clones Mattermost's Docker repo, creates `.env`, creates data directories with the right permissions |
| `scripts/03-start-mattermost.sh` | Starts Mattermost without the bundled nginx layer |
| `scripts/04-setup-tailscale.sh` | Installs Tailscale and serves Mattermost over HTTPS on your private network |
| `scripts/backup.sh` | Dumps the Postgres database and archives the data volumes, keeping the last 14 days |
| `scripts/update.sh` | Pulls newer images and restarts the stack |

Read each script before running it. They are short on purpose.

## Security notes

- Use `tailscale serve`, not `tailscale funnel`. Funnel exposes the port to the public internet.
- Change the sample database password before first start and store it in a password manager.
- Pin a Mattermost version in `.env` instead of using `latest`, and update every couple of months.
- Keep the server's operating system patched with `sudo apt update && sudo apt upgrade`.
- Test a backup restore at least once. A backup you have never restored is only a hope.

## Scope

Mattermost's own documentation describes this Docker Compose setup as suitable for small teams and not for clustered or high-availability deployments. For 5 to 20 people on one office server, that is the right amount of infrastructure. If you outgrow it, see the Mattermost deployment docs.

## Sources

- https://mattermost.com/install
- https://github.com/mattermost/docker
- https://tailscale.com/kb/1242/tailscale-serve

## License

MIT, see [LICENSE](LICENSE).

Maintained by FUSE Computer Solutions.
