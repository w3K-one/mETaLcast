# mETaLcast — Docker Hub Description

## Short description (100 chars max)

```
AzuraCast fork by w3K LLC — custom domain routing, clean /listen URLs, no-QEMU multi-arch builds.
```

## Full description (paste into Docker Hub → Repository → Edit → Full Description)

---

# mETaLcast

A customized fork of [AzuraCast](https://github.com/AzuraCast/AzuraCast) built by **[w3K LLC](https://w3k.one)** to power **[mETaLmuSicRaDio](https://mETaLmuSicRaDio.com)** — an internet metal radio station on the air since 1996.

If you want stock AzuraCast, use the [official image](https://hub.docker.com/r/azuracast/azuracast). This image adds w3K's enhancements and is maintained for production use.

## What's added over upstream AzuraCast

**Custom public page domain per station**  
Point any domain at a station's player. AzuraCast serves the full public page at the domain root — no `/public/slug` path needed. Configured in the station's Profile settings. nginx is generated and reloaded automatically.

**Clean `/listen` stream URL on custom domains**  
When Web Proxy for Radio is on and a custom domain is set, the stream becomes `https://yourcustomdomain.com/listen` instead of `https://main-domain.com/listen/station-slug`.

**Native multi-arch — no QEMU**  
amd64 and arm64 built on native GitHub-hosted runners and merged into a single manifest. Runs on x86 servers and Oracle Cloud ARM, Raspberry Pi, Apple Silicon VMs without any emulation overhead.

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from `main` branch |
| `rolling` | Same as `latest` — alias for AzuraCast-compatible stack references |
| `main` | Main branch build |
| `stable` | Stable branch build |
| `x.y.z` | Version release |

## Quick start

```yaml
services:
  ac:
    image: w3kllc/metalcast:rolling
    ports:
      - '80:80'
      - '443:443'
      - '2022:2022'
      - '8000:8000'
    volumes:
      - station_data:/var/azuracast/stations
      - db:/var/lib/mysql
      - backups:/var/azuracast/backups
    environment:
      MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: "yes"
      MARIADB_USER: "azuracast"
      MARIADB_PASSWORD: "changeme"
      MARIADB_DATABASE: "azuracast"
      MYSQL_USER: "azuracast"
      MYSQL_PASSWORD: "changeme"
      MYSQL_DATABASE: "azuracast"
    restart: unless-stopped

volumes:
  station_data: {}
  db: {}
  backups: {}
```

> MariaDB 11.x (shipped with this image) requires explicit `MARIADB_*` variables on first boot alongside `MYSQL_*`. All six shown above are required.

## Source & License

- GitHub: [github.com/w3k-one/mETaLcast](https://github.com/w3k-one/mETaLcast)  
- License: [AGPL-3.0](https://github.com/w3k-one/mETaLcast/blob/main/LICENSE.md)  
- Upstream: [AzuraCast/AzuraCast](https://github.com/AzuraCast/AzuraCast)

Built by **[w3K LLC](https://w3k.one)** · Boynton Beach, FL
