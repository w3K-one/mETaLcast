#!/usr/bin/env bash
# Sync with upstream AzuraCast and re-apply all w3K patches.
#
# Usage:
#   bash patches/sync-upstream.sh            # sync to upstream/main
#   bash patches/sync-upstream.sh v0.20.1    # sync to a specific upstream tag
#
# What it does:
#   1. Fetches upstream
#   2. Copies patches + w3K-assets to /tmp (they disappear on branch switch)
#   3. Creates a temp branch at upstream/main (or specified ref)
#   4. Applies all patches in order via git am
#   5. Copies w3K-assets overlay (images — never patched, always overwritten)
#   6. On success: fast-forwards main, cleans up temp files
#   7. On conflict: leaves you on the temp branch to resolve, then run:
#        git add <file> && git am --continue
#        git checkout main && git merge --ff-only sync-upstream-tmp
#        bash patches/generate-patches.sh
set -euo pipefail

PATCHES_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$PATCHES_DIR/.." && pwd)"
UPSTREAM_REF="${1:-upstream/main}"
TMP_BRANCH="sync-upstream-tmp"
TMP_WORK="$(mktemp -d)"

cd "$REPO_ROOT"

if ! git remote get-url upstream &>/dev/null; then
    echo "ERROR: 'upstream' remote not set. Add it with:"
    echo "  git remote add upstream https://github.com/AzuraCast/AzuraCast.git"
    exit 1
fi

echo "Fetching upstream..."
git fetch upstream --quiet --tags

# Stash patches and assets before switching branches — they live on our
# branch only and git removes them when we check out upstream/main.
echo "Stashing patches and w3K-assets to $TMP_WORK..."
cp -r "$PATCHES_DIR" "$TMP_WORK/patches"
[ -d "$REPO_ROOT/w3K-assets" ] && cp -r "$REPO_ROOT/w3K-assets" "$TMP_WORK/w3K-assets"

cleanup() {
    rm -rf "$TMP_WORK"
}
trap cleanup EXIT

echo "Creating temp branch at $UPSTREAM_REF..."
git checkout -B "$TMP_BRANCH" "$UPSTREAM_REF"

echo "Applying w3K patches..."
for patch in "$TMP_WORK/patches"/*.patch; do
    echo "  -> $(basename "$patch")"
    git am "$patch" || {
        echo ""
        echo "CONFLICT in $(basename "$patch")"
        echo ""
        echo "You are on branch: $TMP_BRANCH"
        echo "Patches are in:    $TMP_WORK/patches/"
        echo ""
        echo "Resolve the conflict, then:"
        echo "  git add <resolved files>"
        echo "  git am --continue"
        echo "  git checkout main && git reset --hard $TMP_BRANCH"
        echo "  git branch -d $TMP_BRANCH"
        echo "  bash patches/generate-patches.sh"
        echo ""
        echo "Note: temp files in $TMP_WORK — do not close this shell before finishing."
        trap - EXIT  # don't delete tmp on exit while conflict is unresolved
        exit 1
    }
done

echo "All patches applied cleanly."

# Apply w3K asset overlay — immune to upstream image changes.
if [ -d "$TMP_WORK/w3K-assets" ]; then
    echo "Applying w3K asset overlay..."
    cp -rf "$TMP_WORK/w3K-assets"/. "$REPO_ROOT/"
    git add -A
    if ! git diff --cached --quiet; then
        git commit -m "chore: apply w3K asset overlay after upstream sync"
    fi
fi

echo "Updating main to synced state..."
git checkout main
git reset --hard "$TMP_BRANCH"
git branch -D "$TMP_BRANCH"

echo ""
echo "Done. main is now at: $(git log --oneline -1)"
echo "Regenerating patch files..."
bash "$PATCHES_DIR/generate-patches.sh"
echo ""
echo "Push when ready: git push --force-with-lease origin main"
