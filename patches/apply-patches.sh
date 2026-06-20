#!/usr/bin/env bash
# Apply all w3K patches to the current branch in order.
# Run this after checking out a clean upstream state.
set -euo pipefail

PATCHES_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$PATCHES_DIR/.." && pwd)"

echo "Applying patches from $PATCHES_DIR..."

cd "$REPO_ROOT"

for patch in "$PATCHES_DIR"/*.patch; do
    echo "  -> $(basename "$patch")"
    git am --binary "$patch" || {
        echo ""
        echo "CONFLICT in $patch"
        echo "Fix the conflict, then run:"
        echo "  git add <resolved-files>"
        echo "  git am --continue"
        echo "Or abort with: git am --abort"
        exit 1
    }
done

echo "All patches applied."
