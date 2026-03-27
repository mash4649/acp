#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_SCRIPT="$ROOT_DIR/scripts/conformance.sh"
REPORT_PATH="${ACP_CONFORMANCE_REPORT:-$ROOT_DIR/conformance/out/report.phase1.json}"
MODE="${ACP_CONFORMANCE_MODE:-mock}"

usage() {
  cat <<USAGE
Usage:
  ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh
  ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh
  ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh
  ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh

Modes:
  mock              Always run mock report generation.
  reference         Run the repo-local reference harness.
  external          Run external if ACP_HARNESS_RUNNER is set, otherwise fall back to reference.
  required-external Require ACP_HARNESS_RUNNER and fail if not available.
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

validate_report_shape() {
  local report="$1"
  jq -e '
    has("run_id") and
    has("profile_id") and
    has("status") and
    has("generated_at") and
    has("summary") and
    has("results")
  ' "$report" >/dev/null
}

profile_args() {
  if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
    printf '%s\n' "--profile ${ACP_CONFORMANCE_PROFILE}"
  fi
}

reject_known_mock_runner() {
  local runner="${ACP_HARNESS_RUNNER:-}"
  local base
  base="$(basename "$runner")"
  if [[ "$base" == "mock_external_runner.sh" ]]; then
    echo "CI gate failed: required-external mode rejects known mock runners." >&2
    exit 1
  fi
}

gate_mock() {
  local report="$1"
  local status failed
  status="$(jq -r '.status' "$report")"
  failed="$(jq -r '.summary.failed // 0' "$report")"

  if [[ "$failed" != "0" ]]; then
    echo "CI gate failed: summary.failed must be 0 in mock mode (actual: $failed)" >&2
    exit 1
  fi

  if [[ "$status" != "mock" && "$status" != "pass" ]]; then
    echo "CI gate failed: status must be mock/pass in mock mode (actual: $status)" >&2
    exit 1
  fi
}

gate_external() {
  local report="$1"
  local status failed
  status="$(jq -r '.status' "$report")"
  failed="$(jq -r '.summary.failed // 0' "$report")"

  if [[ "$status" != "pass" ]]; then
    echo "CI gate failed: external mode requires status=pass (actual: $status)" >&2
    exit 1
  fi

  if [[ "$failed" != "0" ]]; then
    echo "CI gate failed: summary.failed must be 0 in external mode (actual: $failed)" >&2
    exit 1
  fi
}

gate_reference() {
  local report="$1"
  local status failed
  status="$(jq -r '.status' "$report")"
  failed="$(jq -r '.summary.failed // 0' "$report")"

  if [[ "$status" != "pass" ]]; then
    echo "CI gate failed: reference mode requires status=pass (actual: $status)" >&2
    exit 1
  fi

  if [[ "$failed" != "0" ]]; then
    echo "CI gate failed: summary.failed must be 0 in reference mode (actual: $failed)" >&2
    exit 1
  fi
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_cmd jq
  [[ -x "$RUNNER_SCRIPT" ]] || { echo "Missing executable runner: $RUNNER_SCRIPT" >&2; exit 1; }

  if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
    "$RUNNER_SCRIPT" doctor --profile "$ACP_CONFORMANCE_PROFILE"
  else
    "$RUNNER_SCRIPT" doctor
  fi

  case "$MODE" in
    mock)
      if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
        "$RUNNER_SCRIPT" run --mock --profile "$ACP_CONFORMANCE_PROFILE" --report "$REPORT_PATH"
      else
        "$RUNNER_SCRIPT" run --mock --report "$REPORT_PATH"
      fi
      validate_report_shape "$REPORT_PATH"
      gate_mock "$REPORT_PATH"
      ;;
    reference)
      if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
        "$RUNNER_SCRIPT" run --reference --profile "$ACP_CONFORMANCE_PROFILE" --report "$REPORT_PATH"
      else
        "$RUNNER_SCRIPT" run --reference --report "$REPORT_PATH"
      fi
      validate_report_shape "$REPORT_PATH"
      gate_reference "$REPORT_PATH"
      ;;
    external)
      if [[ -n "${ACP_HARNESS_RUNNER:-}" ]]; then
        if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
          "$RUNNER_SCRIPT" run --profile "$ACP_CONFORMANCE_PROFILE" --report "$REPORT_PATH"
        else
          "$RUNNER_SCRIPT" run --report "$REPORT_PATH"
        fi
        validate_report_shape "$REPORT_PATH"
        gate_external "$REPORT_PATH"
      else
        echo "ACP_HARNESS_RUNNER is not set. Falling back to reference mode."
        if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
          "$RUNNER_SCRIPT" run --reference --profile "$ACP_CONFORMANCE_PROFILE" --report "$REPORT_PATH"
        else
          "$RUNNER_SCRIPT" run --reference --report "$REPORT_PATH"
        fi
        validate_report_shape "$REPORT_PATH"
        gate_reference "$REPORT_PATH"
      fi
      ;;
    required-external)
      if [[ -z "${ACP_HARNESS_RUNNER:-}" ]]; then
        echo "CI gate failed: required-external mode needs ACP_HARNESS_RUNNER." >&2
        exit 1
      fi
      reject_known_mock_runner
      if [[ -n "${ACP_CONFORMANCE_PROFILE:-}" ]]; then
        "$RUNNER_SCRIPT" run --profile "$ACP_CONFORMANCE_PROFILE" --report "$REPORT_PATH"
      else
        "$RUNNER_SCRIPT" run --report "$REPORT_PATH"
      fi
      validate_report_shape "$REPORT_PATH"
      gate_external "$REPORT_PATH"
      ;;
    *)
      echo "Unknown ACP_CONFORMANCE_MODE: $MODE" >&2
      usage
      exit 1
      ;;
  esac

  echo "conformance-ci: ok (mode=$MODE report=$REPORT_PATH)"
}

main "$@"
