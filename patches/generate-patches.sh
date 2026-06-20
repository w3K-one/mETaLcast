#!/usr/bin/env bash
# Regenerate all patches from current commits on top of upstream/main.
# Run this after amending a patch commit or adding a new one.
set -euo pipefail

PATCHES_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$PATCHES_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Ensure upstream remote exists
if ! git remote get-url upstream &>/dev/null; then
    echo "ERROR: 'upstream' remote not set. Add it with:"
    echo "  git remote add upstream https://github.com/AzuraCast/AzuraCast.git"
    exit 1
fi

echo "Fetching upstream..."
git fetch upstream --quiet

echo "Removing old patches..."
rm -f "$PATCHES_DIR"/*.patch

echo "Generating patches from upstream/main..HEAD..."
# Excluded from patches (handled outside the patch system):
#   frontend/img/   — binary assets, applied via w3K-assets/ overlay in sync-upstream.sh
#   patches/*.patch — patch files are regenerated, never re-applied as a patch
git format-patch \
    --output-directory "$PATCHES_DIR" \
    upstream/main..HEAD \
    -- ':!frontend/img/' ':!patches/*.patch'

echo "Generated:"
ls "$PATCHES_DIR"/*.patch | while read -r f; do echo "  $(basename "$f")"; done
