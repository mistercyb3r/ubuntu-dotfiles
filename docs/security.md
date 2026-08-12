# Security

## Repository rules

- No passwords, API keys, tokens, or private keys
- No hard-coded usernames or hostnames
- `.gitignore` plus a global `core.excludesfile` ignore `.env`, keys, and credential filenames
- `scripts/check-secrets.sh` and `.github/workflows/secret-scan.yml` catch obvious accidents

If a secret is committed: rotate it immediately; history rewrite is not enough if the repo was pushed.

## SSH

- Client configuration only
- `openssh-server` is not installed or enabled by this project
- Do not port-forward 22 from the public internet
- Prefer Tailscale to a home server
- `IdentitiesOnly yes` avoids offering the wrong key

## Docker

Membership of `docker` is equivalent to root. The installer asks before `usermod -aG docker`.

## Firewall

UFW/nftables rules are **not** changed. If you enable UFW later, allow only what you need; Tailscale does not require opening SSH to the world.

## Kernel / firmware

- No `mitigations=off`
- No overclocking
- No custom sysctl for “performance”
- `fwupdmgr get-updates` is reported by `system-update`; nothing is applied automatically

## Telemetry

This repo does not install extra telemetry. Ubuntu's own `ubuntu-report` / popularity-contest are left as the OS shipped them. To opt out of Ubuntu report:

```bash
ubuntu-report send no
```

(Only if that command exists on your install.)

## GNOME lock

The screensaver lock stays enabled. Location services are turned off.

## Secrets in projects

```bash
cp .env.example .env
check-secrets .
```

Cursor and other AI tools should not be given production secrets in chat. Use `.env` locally.
