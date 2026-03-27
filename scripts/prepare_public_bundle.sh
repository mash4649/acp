#!/usr/bin/env bash
set -euo pipefail

# Copies the curated public bundle from release/distribution_bundle/ to a destination directory.
# The canonical, versioned tree lives under release/distribution_bundle/ (not project/public_assets/).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL="$ROOT_DIR/release/distribution_bundle"
DEST="${1:-$ROOT_DIR/dist/public_bundle}"

if [[ ! -d "$CANONICAL" ]]; then
  echo "Missing canonical bundle: $CANONICAL" >&2
  exit 1
fi

mkdir -p "$DEST"
rsync -a --delete \
  --exclude '.git' \
  --exclude '.tmp' \
  "$CANONICAL/" "$DEST/"

echo "public-bundle: copied $CANONICAL -> $DEST"
