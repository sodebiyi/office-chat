# Launch Checklist

- [ ] Spare PC has a fixed local IP and Docker installed
- [ ] Mattermost is up at `http://<server-ip>:8065` and the System Admin account is created
- [ ] Database password changed from the sample value and stored in a password manager
- [ ] Mattermost version pinned in `.env`
- [ ] Team and starter channels created
- [ ] Tailscale installed on the server and `tailscale serve` running
- [ ] Site URL in System Console set to the `.ts.net` address
- [ ] Every employee device has Tailscale installed and is signed into the organization
- [ ] Everyone has the Mattermost app pointed at the `.ts.net` address
- [ ] Nightly backup scheduled and a restore tested once
