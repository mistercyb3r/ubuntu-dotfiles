# Tailscale

Use Tailscale so this laptop can reach a home server **without** exposing SSH on the public internet.

## What the installer does

- Optionally installs the `tailscale` package (full profile, after confirmation)
- Adds Tailscale's official apt repository if Ubuntu does not ship the package
- **Does not** run `tailscale up`
- **Does not** accept or store an auth key
- **Does not** change firewall rules

## Log in (on the laptop)

```bash
sudo tailscale up
tailscale status
tailscale ip -4
```

Complete the browser login as yourself. Do not paste auth keys into this repository or into shell history files you might commit.

## Home server

On the server (separately):

```bash
sudo tailscale up
```

Prefer MagicDNS names (`homeserver.tail-xxxx.ts.net`) over copying IPs that can change.

## SSH config

```bash
cp ~/.ssh/config.d/homelab.conf.example ~/.ssh/config.d/10-homeserver.conf
chmod 600 ~/.ssh/config.d/10-homeserver.conf
```

Edit placeholders:

```text
Host homeserver
    HostName <TAILSCALE_IP_OR_MAGICDNS_NAME>
    User <USERNAME>
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Then:

```bash
server ssh homeserver
```

## Do not

- Port-forward TCP 22 on the router to either machine
- Run `tailscale up --auth-key=...` from a file in this repo
- Disable the laptop firewall “to make Tailscale work” (it does not need that)
