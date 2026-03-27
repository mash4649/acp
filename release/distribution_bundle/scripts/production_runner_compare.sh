#!/usr/bin/env bash
set -euo pipefail

# Convenience wrapper: same profile, two production harness runners, parity on reports.
# Requires ACP_HARNESS_RUNNER and ACP_HARNESS_RUNNER_2 (both non-mock adapters).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ACP_PARITY_MODE="${ACP_PARITY_MODE:-runner-runner}"
export ACP_CONFORMANCE_PROFILE="${ACP_CONFORMANCE_PROFILE:-conformance/profiles/phase3.profile.json}"

usage() {
  cat <<'EOF'
Usage:
  ACP_HARNESS_RUNNER=/path/runner-a ACP_HARNESS_RUNNER_2=/path/runner-b \\
    ./scripts/production_runner_compare.sh

Optional:
  ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json
  ACP_PARITY_OUT_DIR=conformance/out/parity

Delegates to ./scripts/conformance_parity.sh (ACP_PARITY_MODE=runner-runner).
EOF
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  exec "$ROOT_DIR/scripts/conformance_parity.sh" "$@"
}

main "$@"
