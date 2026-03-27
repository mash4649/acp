#!/usr/bin/env bash
set -euo pipefail

# Reproducible v1 audit: install conformance deps, run all gates, refresh evidence logs under conformance/out/.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/conformance/out"
RUNNER="$ROOT_DIR/scripts/acp_harness_runner.sh"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify_v1_bundle.sh

Runs, in order:
  1) ./scripts/install_conformance_deps.sh
  2) ./scripts/public_release_check.sh        -> conformance/out/v1-evidence.public_release_check.txt
  3) ./scripts/conformance_selftest.sh         -> conformance/out/v1-evidence.conformance_selftest.txt
  4) ACP_HARNESS_RUNNER=<bundled> ./scripts/external_release_gate.sh
                                                -> conformance/out/v1-evidence.required_external.txt (+ release-gate/)
  5) ./scripts/security_ops_minimum.sh all      -> conformance/out/v1-evidence.security_ops_minimum.txt

Requires: jq, python3, pip network access for step 1.
EOF
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  mkdir -p "$OUT_DIR"
  "$ROOT_DIR/scripts/install_conformance_deps.sh"
  "$ROOT_DIR/scripts/public_release_check.sh" 2>&1 | tee "$OUT_DIR/v1-evidence.public_release_check.txt"
  "$ROOT_DIR/scripts/conformance_selftest.sh" 2>&1 | tee "$OUT_DIR/v1-evidence.conformance_selftest.txt"
  ACP_HARNESS_RUNNER="$RUNNER" "$ROOT_DIR/scripts/external_release_gate.sh" 2>&1 | tee "$OUT_DIR/v1-evidence.required_external.txt"
  "$ROOT_DIR/scripts/security_ops_minimum.sh" all 2>&1 | tee "$OUT_DIR/v1-evidence.security_ops_minimum.txt"
  echo "verify_v1_bundle: ok"
}

main "$@"
