# mETaLcast Patches

w3K LLC modifications to AzuraCast, maintained as discrete patches so they
can be re-applied cleanly after each upstream sync.

## Current patches

| # | File | Description |
|---|------|-------------|
| 0001 | `0001-ci-native-...patch` | Native multi-arch CI (no QEMU), push to w3kllc/metalcast + ghcr.io/w3k-one/metalcast |
| 0002 | `0002-docs-mETaLcast-...patch` | mETaLcast README and Docker Hub description |
| 0003 | `0003-feat-per-station-...patch` | Per-station custom public page domain + clean `/listen` stream URL |
| 0004 | `0004-feat-mETaLmuSicRaDio-...patch` | Red/dark color scheme: SCSS variables only (images live in `w3K-assets/`) |
| 0005 | `0005-chore-w3K-asset-overlay-...patch` | `w3K-assets/` overlay + sync script copies images after every sync |

## Syncing with upstream AzuraCast

```bash
bash patches/sync-upstream.sh
```

To sync to a specific upstream tag instead of main:
```bash
bash patches/sync-upstream.sh v0.20.1
```

On conflict, the script leaves you on a temp branch. Fix the conflict,
run `git am --continue`, then regenerate patches and merge.

## Adding a new w3K modification

1. Make your changes on `main` as one or more clean, descriptive commits
2. Regenerate all patches:
   ```bash
   bash patches/generate-patches.sh
   ```
3. Commit the updated `patches/` directory alongside your code changes

## Modifying an existing patch

1. Use `git rebase -i upstream/main` to edit the relevant commit
2. Make your changes and `git rebase --continue`
3. Regenerate patches:
   ```bash
   bash patches/generate-patches.sh
   ```

## How it works

- `apply-patches.sh` — applies all `*.patch` files via `git am --binary`
- `generate-patches.sh` — regenerates all patches from `upstream/main..HEAD`
- `sync-upstream.sh` — full sync workflow: fetch upstream → temp branch → apply patches → fast-forward main

Patches are generated with `git format-patch --binary` so binary assets
(images) are included correctly.
