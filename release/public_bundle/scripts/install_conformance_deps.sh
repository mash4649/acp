#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY_TAG="$(python3 - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
)"
TARGET_DIR="${1:-$ROOT_DIR/.tmp/conformance-deps-$PY_TAG}"
REQ_FILE="$ROOT_DIR/requirements-conformance.lock"

if [[ ! -f "$REQ_FILE" ]]; then
  REQ_FILE="$ROOT_DIR/requirements-conformance.txt"
fi

mkdir -p "$ROOT_DIR/.tmp"
python3 -m pip install --upgrade --force-reinstall --target "$TARGET_DIR" -r "$REQ_FILE"
echo "conformance-deps: using $REQ_FILE"
echo "conformance-deps: installed to $TARGET_DIR"
