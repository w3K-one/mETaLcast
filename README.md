# mETaLcast

[![Build Status](https://github.com/w3k-one/mETaLcast/workflows/w3K—Build—Em-All/badge.svg)](https://github.com/w3k-one/mETaLcast/actions)
[![Docker Hub](https://img.shields.io/docker/pulls/w3kllc/metalcast.svg?label=Docker+Hub)](https://hub.docker.com/r/w3kllc/metalcast)
[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Fw3k--one%2Fmetalcast-blue)](https://ghcr.io/w3k-one/metalcast)
[![AGPL-3.0 License](https://img.shields.io/github/license/azuracast/azuracast.svg)](LICENSE.md)

**mETaLcast** is a customized fork of [AzuraCast](https://github.com/AzuraCast/AzuraCast) built and operated by **[w3K LLC](https://w3k.one)** to power **[mETaLmuSicRaDio](https://mETaLmuSicRaDio.com)** — an internet metal radio station broadcasting 24/7/369 since 1996.

It is a complete, self-hosted web radio management suite that runs cleanly on Docker. If you want vanilla AzuraCast, use [the upstream project](https://github.com/AzuraCast/AzuraCast). If you want the metal edition with w3K's additions, you are in the right place.

---

## What's Different from Upstream AzuraCast

### Per-Station Custom Public Page Domain

Assign any domain directly to a station's public player page. When set, AzuraCast serves the station player at the root of that domain — no `/public/station-slug` path in the URL.

Set it in **Admin → Stations → Edit → Profile (Advanced) → Custom Public Page Domain**.

Nginx configuration is generated and reloaded automatically.

### Clean Stream URLs on Custom Domains

With **Use Web Proxy for Radio** enabled and a custom domain set, the stream URL becomes:

```
https://yourcustomdomain.com/listen
```

Instead of:

```
https://yourazuracastdomain.com/listen/station-slug
```

Every station with a custom domain gets its own clean `/listen` endpoint. Scales to as many stations as your server can handle.

### Multi-Arch Docker Images — No QEMU

Builds run natively on `ubuntu-latest` (amd64) and `ubuntu-24.04-arm` (arm64) in parallel, with manifests merged at the end. No QEMU emulation. Fast builds.

Images are published to:
- `w3kllc/metalcast` on Docker Hub
- `ghcr.io/w3k-one/metalcast` on GitHub Container Registry

Tags: `latest`, `rolling` (both on main branch push), version tags on releases, branch names on branch pushes.

---

## Installation

mETaLcast uses the same Docker-based installation as upstream AzuraCast. Replace `azuracast/azuracast` with `w3kllc/metalcast` (or `ghcr.io/w3k-one/metalcast`) in your compose file.

See the [AzuraCast installation docs](https://www.azuracast.com/docs/getting-started/installation/) for full instructions — everything applies here.

### Quick docker-compose snippet

```yaml
services:
  ac:
    image: w3kllc/metalcast:rolling
    # or: ghcr.io/w3k-one/metalcast:rolling
    ports:
      - '80:80'
      - '443:443'
      - '2022:2022'
      - '8000:8000'
      # add more station ports as needed (8010, 8020, ...)
    volumes:
      - station_data:/var/azuracast/stations
      - db:/var/lib/mysql
      # add other volumes
    environment:
      MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: "yes"
      MARIADB_USER: "your_db_user"
      MARIADB_PASSWORD: "your_db_password"
      MARIADB_DATABASE: "your_db_name"
      MYSQL_USER: "your_db_user"
      MYSQL_PASSWORD: "your_db_password"
      MYSQL_DATABASE: "your_db_name"
    restart: unless-stopped
```

> **Note:** MariaDB 11.x requires the `MARIADB_*` environment variables for initialization. All six variables above are required on first boot.

---

## Architecture

mETaLcast is built on the same stack as AzuraCast:

- **Liquidsoap** — AutoDJ engine
- **Icecast2** — Streaming server
- **nginx** — Reverse proxy and public page routing
- **MariaDB** — Station and schedule database
- **PHP 8.4** — Application backend
- **Vue 3** — Frontend

---

## Upstream Credit

mETaLcast is a fork of **AzuraCast** by [Buster "Silver Eagle" Neece](https://github.com/SlvrEagleDev) and the AzuraCast contributors. All upstream code is licensed under the [AGPL-3.0](LICENSE.md). Respect to everyone who built the original — it is excellent software.

- Upstream repo: [AzuraCast/AzuraCast](https://github.com/AzuraCast/AzuraCast)
- Upstream docs: [azuracast.com](https://www.azuracast.com/)

---

## Built by

**[w3K LLC](https://w3k.one)** — IT Infrastructure, Networking & AI Systems  
Boynton Beach, FL · [i@w3k.co](mailto:i@w3k.co)

**[mETaLmuSicRaDio](https://mETaLmuSicRaDio.com)** has been on the air since 1996... 24/7/369 (mETaLheads get extra days 🤘😎).
