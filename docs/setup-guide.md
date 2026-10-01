# Setup Guide

A private team chat workspace running on a spare office PC, reachable from the office, from home and from phones.

Platform: Mattermost (free, open source). Remote access: Tailscale. Team size: 5 to 20. Time to first login: about 30 minutes.

## 1. The plan in short

You do not need to build a chat app, you need to run one well. Mattermost is a self-hosted alternative to Slack with channels, direct messages, file sharing, search, mentions, and phone and desktop apps. It is actively maintained, has no per-user fee for the features a small team needs, and because it runs in Docker it lives entirely on hardware in your office.

For getting to it from outside the office, Tailscale creates a private encrypted network between the server and each employee's laptop or phone. There are no ports to open on the router, no public IP and no certificates to manage. Each device needs the Tailscale app and a login.

## 2. Prepare the spare PC

Mattermost is light. A machine with 2 or more CPU cores, 4 GB RAM and 20 GB or more of free disk comfortably serves a 5 to 20 person team. What matters more is running an operating system you are comfortable leaving on and keeping updated.

**Ubuntu Server LTS (recommended).** Wipe the PC and install Ubuntu Server. It is lighter and more stable for a machine that runs around the clock, and every command in this guide works as written.

**Keep the existing Windows install.** Install WSL2, then Docker Desktop for Windows. This works, but the PC has to stay powered on and logged in, and Windows updates will sometimes need a reboot you have to handle yourself.

Before you start, give the PC a fixed local IP. Either set a DHCP reservation in your router's admin page or configure a static IP on the machine, so the address does not change after a reboot.

## 3. Install Docker

These steps assume Ubuntu Server. On Windows, install Docker Desktop with the WSL2 backend and skip to section 4. The compose commands are identical from a WSL terminal.

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# log out and back in so the group change takes effect
```

Confirm it works:

```bash
docker --version
docker compose version
```

Or run `scripts/01-install-docker.sh`, which does the same thing.

## 4. Deploy Mattermost

Mattermost publishes an official Docker Compose setup. The commands below pull it down and start the server on port 8065.

```bash
git clone https://github.com/mattermost/docker
cd docker
cp env.example .env
```

Edit `.env` and set at least the following.

| Variable | Set it to |
| --- | --- |
| `DOMAIN` | The server's local IP or hostname for now, for example `192.168.1.50`. You will add the Tailscale name in section 6 |
| `MATTERMOST_IMAGE_TAG` | A pinned version such as `release-10.5` rather than `latest` |
| Database password fields | A strong password stored in a password manager, not the sample value |

Create the data directories with the permissions Mattermost expects:

```bash
mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}
sudo chown -R 2000:2000 ./volumes/app/mattermost
```

Start it without the bundled nginx and HTTPS layer, since Tailscale Serve handles HTTPS in section 6:

```bash
docker compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```

From any browser on the office network, go to `http://<server-ip>:8065`. You should see Mattermost's setup screen.

The scripts `02-prepare-mattermost.sh` and `03-start-mattermost.sh` wrap these steps.

Note: Mattermost's own docs say this compose setup is fine for a small team but not built for clustered or high-availability use. For 5 to 20 people on one server, that is the right amount of infrastructure.

## 5. First login and inviting the team

1. On the setup screen, create the first account. It automatically becomes the System Admin, so use a real work email and a strong password. This account can see and configure everything.
2. Create your first Team, which is the top-level workspace. Most offices only need one, named after the company. Add a few starter channels such as `#general`, `#announcements` (post-only for management) and one per department.
3. Go to System Console, then User Management. Either invite people by email, or turn on an invite link you can send in an email or put on a printout.
4. Have each employee install the Mattermost desktop or mobile app and point it at your server address. This is the same URL as the browser, once section 6 gives it a stable remote address.

## 6. Remote access without opening your router

Tailscale puts the server and every employee device on one private network, encrypted end to end, with no public port exposed to the internet.

Install and connect Tailscale on the server:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

This prints a login link. Open it once to add the server to your organization's Tailscale account.

Turn on Tailscale Serve to give the chat server an HTTPS address on your private network, pointed at the port Mattermost already uses:

```bash
sudo tailscale serve --bg 8065
```

Tailscale returns an address like `https://office-chat.your-tailnet.ts.net`. That is the one URL everyone uses from now on, in the office or out. Set the Site URL in System Console to the same address.

Install the Tailscale app on each employee's laptop and phone, sign them into the same organization, and share the `.ts.net` address. Once connected, Mattermost works on desktop, mobile, home wifi and anywhere else.

**Why this instead of a domain and an open port.** The alternative of buying a domain, forwarding a port and running your own certificate works, but it puts a server on the public internet that needs ongoing patching and monitoring. Tailscale Serve gives the same convenience while keeping the server invisible to anyone not on your private network. `tailscale funnel` makes the service public, so avoid it unless you have a specific reason.

## 7. Backups and updates

Back up the database regularly, since it holds every message and file. A nightly job that dumps Postgres and copies the result to a second disk or external drive is enough at this scale:

```bash
docker compose exec postgres pg_dump -U mmuser mattermost > backup-$(date +%F).sql
```

`scripts/backup.sh` does this and also archives the data volumes. To schedule it nightly at 02:00:

```bash
crontab -e
# add:
0 2 * * * /path/to/office-chat/scripts/backup.sh >> /var/log/mattermost-backup.log 2>&1
```

Update every couple of months rather than on release day. Bump `MATTERMOST_IMAGE_TAG` in `.env` to a newer pinned version, then run `scripts/update.sh`, or manually:

```bash
docker compose pull
docker compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```

Check System Console, then Server Logs, now and then, and keep the server OS patched with `sudo apt update && sudo apt upgrade`.

Test a restore once before you rely on the backups: restore the dump into a fresh Postgres volume, start the stack and confirm the messages are there.

## 8. Launch checklist

See [launch-checklist.md](launch-checklist.md).
