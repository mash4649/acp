#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ACP_RELEASE_GATE_OUT_DIR:-$ROOT_DIR/conformance/out/release-gate}"
PROFILE="${ACP_CONFORMANCE_PROFILE:-conformance/profiles/phase3.profile.json}"
RUNNER="${ACP_HARNESS_RUNNER:-}"

usage() {
  cat <<'EOF'
Usage:
  ACP_HARNESS_RUNNER=/path/to/prod-runner ./scripts/external_release_gate.sh

Optional env:
  ACP_CONFORMANCE_PROFILE=conformance/profiles/phase3.profile.json
  ACP_RELEASE_GATE_OUT_DIR=conformance/out/release-gate

What this script does:
  1) Runs required-external gate
  2) Copies report and summary evidence into release-gate output
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_cmd jq
  [[ -n "$RUNNER" ]] || { echo "ACP_HARNESS_RUNNER is required." >&2; exit 1; }
  if ! command -v "$RUNNER" >/dev/null 2>&1 && [[ ! -x "$RUNNER" ]]; then
    echo "ACP_HARNESS_RUNNER is not executable: $RUNNER" >&2
    exit 1
  fi

  mkdir -p "$OUT_DIR"

  local report_path="$OUT_DIR/report.required-external.json"
  local summary_path="$OUT_DIR/summary.required-external.json"
  local env_path="$OUT_DIR/env.required-external.txt"

  ACP_CONFORMANCE_MODE=required-external \
  ACP_HARNESS_RUNNER="$RUNNER" \
  ACP_CONFORMANCE_PROFILE="$PROFILE" \
  ACP_CONFORMANCE_REPORT="$report_path" \
  "$ROOT_DIR/scripts/conformance_ci.sh"

  jq -n \
    --arg mode "required-external" \
    --arg profile "$PROFILE" \
    --arg runner "$RUNNER" \
    --arg status "$(jq -r '.status' "$report_path")" \
    --argjson failed "$(jq '.summary.failed // 0' "$report_path")" \
    --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
      mode: $mode,
      profile: $profile,
      runner: $runner,
      report_status: $status,
      summary_failed: $failed,
      generated_at: $generated_at
    }' >"$summary_path"

  {
    echo "ACP_HARNESS_RUNNER=$RUNNER"
    echo "ACP_CONFORMANCE_PROFILE=$PROFILE"
    echo "ACP_CONFORMANCE_MODE=required-external"
  } >"$env_path"

  echo "external-release-gate: ok"
  echo "report: $report_path"
  echo "summary: $summary_path"
  echo "env: $env_path"
}

main "$@"
