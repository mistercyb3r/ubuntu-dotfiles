# Docker

## Install policy

- If `docker` already exists, the installer **keeps it**
- Otherwise it uses Docker's official Ubuntu apt repository (not `get.docker.com`)
- The service is enabled; the machine is **not** rebooted
- Adding your user to group `docker` is optional and warned: it is root-equivalent

## After group membership

Log out of GNOME and back in (or `newgrp docker` for one shell).

```bash
docker version
docker compose version
```

## Useful commands

```bash
docker ps
docker images
docker compose up --build
docker compose down
docker compose logs -f
docker system df
```

Cleanup is **not** automatic:

```bash
docker system prune
```

That can delete unused images. The workstation `cleanup-system` script will not run it for you.

## Compose bind to localhost

Templates publish ports as `127.0.0.1:8080:8080` so containers are not advertised on the LAN by default.

## Do not

- Run the Docker daemon with a TCP port on `0.0.0.0`
- Commit `.env` files used by Compose
- Assume `docker` group is “just convenience” — it is privilege
