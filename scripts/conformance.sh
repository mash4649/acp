#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT_PATH="$ROOT_DIR/conformance/harness_contract_v1.json"
DEFAULT_PROFILE="$ROOT_DIR/conformance/profiles/phase1.profile.json"
REPORT_SCHEMA_PATH="$ROOT_DIR/conformance/report.schema.json"
OUT_DIR="$ROOT_DIR/conformance/out"

python_tag() {
  python3 - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
}

CONFORMANCE_PYTHONPATH="$ROOT_DIR/.tmp/conformance-deps-$(python_tag)"

usage() {
  cat <<USAGE
Usage:
  ./scripts/conformance.sh doctor [--profile <path>]
  ./scripts/conformance.sh prepare [--profile <path>] [--request <path>]
  ./scripts/conformance.sh run [--profile <path>] [--request <path>] [--report <path>] [--mock|--reference]

External harness mode:
  ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run

Runner CLI contract:
  <runner> --contract <path> --profile <path> --request <path> --report <path>
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

pythonpath_with_local_deps() {
  if [[ -d "$CONFORMANCE_PYTHONPATH" ]]; then
    if [[ -n "${PYTHONPATH:-}" ]]; then
      printf '%s:%s\n' "$CONFORMANCE_PYTHONPATH" "$PYTHONPATH"
    else
      printf '%s\n' "$CONFORMANCE_PYTHONPATH"
    fi
  else
    printf '%s\n' "${PYTHONPATH:-}"
  fi
}

resolve_profile() {
  local profile="$1"
  if [[ "$profile" = /* ]]; then
    printf '%s\n' "$profile"
  else
    printf '%s\n' "$ROOT_DIR/$profile"
  fi
}

doctor() {
  local profile_path="$1"

  require_cmd jq

  [[ -f "$CONTRACT_PATH" ]] || { echo "Missing contract: $CONTRACT_PATH" >&2; exit 1; }
  [[ -f "$REPORT_SCHEMA_PATH" ]] || { echo "Missing report schema: $REPORT_SCHEMA_PATH" >&2; exit 1; }
  [[ -f "$profile_path" ]] || { echo "Missing profile: $profile_path" >&2; exit 1; }

  jq -e . "$CONTRACT_PATH" >/dev/null
  jq -e . "$REPORT_SCHEMA_PATH" >/dev/null
  jq -e . "$profile_path" >/dev/null

  local manifest
  manifest="$(jq -r '.vector_manifest // empty' "$profile_path")"
  if [[ -n "$manifest" ]]; then
    [[ -f "$ROOT_DIR/$manifest" ]] || { echo "Missing vector manifest: $manifest" >&2; exit 1; }
  fi

  while IFS= read -r rel; do
    [[ -f "$ROOT_DIR/$rel" ]] || { echo "Missing vector file: $rel" >&2; exit 1; }
  done < <(jq -r '.vectors.valid[]? , .vectors.invalid[]?' "$profile_path")

  while IFS= read -r rel; do
    [[ -f "$ROOT_DIR/$rel" ]] || { echo "Missing schema file: $rel" >&2; exit 1; }
  done < <(jq -r '.schema_map[]?' "$profile_path")

  while IFS= read -r rel; do
    [[ -f "$ROOT_DIR/$rel" ]] || { echo "Missing meta registry: $rel" >&2; exit 1; }
  done < <(jq -r '.meta_registries[]?' "$profile_path")

  while IFS= read -r rel; do
    [[ -d "$ROOT_DIR/$rel" ]] || { echo "Missing case directory: $rel" >&2; exit 1; }
    [[ -f "$ROOT_DIR/$rel/expected.json" ]] || { echo "Missing case expected payload: $rel/expected.json" >&2; exit 1; }
    [[ -d "$ROOT_DIR/$rel/artifacts" ]] || { echo "Missing case artifacts directory: $rel/artifacts" >&2; exit 1; }
    jq -e '
      has("case_id") and
      has("expected_status") and
      has("expected_results")
    ' "$ROOT_DIR/$rel/expected.json" >/dev/null
  done < <(jq -r '.cases[]?' "$profile_path")

  echo "doctor: ok"
}

prepare_request() {
  local profile_path="$1"
  local request_path="$2"

  mkdir -p "$(dirname "$request_path")"

  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  jq -n \
    --arg contract "${CONTRACT_PATH#$ROOT_DIR/}" \
    --arg profile "${profile_path#$ROOT_DIR/}" \
    --arg profile_id "$(jq -r '.profile_id' "$profile_path")" \
    --arg generated_at "$now" \
    --arg vector_manifest "$(jq -r '.vector_manifest' "$profile_path")" \
    --argjson schema_map "$(jq -c '.schema_map' "$profile_path")" \
    --argjson vectors "$(jq -c '.vectors' "$profile_path")" \
    --argjson meta_registries "$(jq -c '.meta_registries' "$profile_path")" \
    --argjson cases "$(jq -c '.cases // []' "$profile_path")" \
    '{
      run_id: ("run-" + ($generated_at | gsub("[-:]"; "") | gsub("T"; "") | gsub("Z"; ""))),
      generated_at: $generated_at,
      contract: $contract,
      profile: {
        path: $profile,
        profile_id: $profile_id
      },
      inputs: {
        vector_manifest: $vector_manifest,
        vectors: $vectors,
        schema_map: $schema_map,
        meta_registries: $meta_registries,
        cases: $cases
      }
    }' > "$request_path"

  echo "prepare: wrote $request_path"
}

run_mock() {
  local profile_path="$1"
  local report_path="$2"

  mkdir -p "$(dirname "$report_path")"

  local now valid_count invalid_count total
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  valid_count="$(jq '.vectors.valid | length' "$profile_path")"
  invalid_count="$(jq '.vectors.invalid | length' "$profile_path")"
  total="$((valid_count + invalid_count))"

  jq -n \
    --arg run_id "mock-$(date -u +"%Y%m%d%H%M%S")" \
    --arg profile_id "$(jq -r '.profile_id' "$profile_path")" \
    --arg generated_at "$now" \
    --argjson total "$total" \
    --argjson passed "$total" \
    --argjson failed "0" \
    '{
      run_id: $run_id,
      profile_id: $profile_id,
      status: "mock",
      generated_at: $generated_at,
      summary: {
        total: $total,
        passed: $passed,
        failed: $failed,
        notes: [
          "Mock mode only verifies adapter plumbing. No protocol-level conformance was executed."
        ]
      },
      results: []
    }' > "$report_path"

  echo "run: mock report written to $report_path"
}

run_external() {
  local profile_path="$1"
  local request_path="$2"
  local report_path="$3"

  if [[ -z "${ACP_HARNESS_RUNNER:-}" ]]; then
    echo "ACP_HARNESS_RUNNER is not set. Use --mock or provide external runner path." >&2
    exit 1
  fi

  if ! command -v "$ACP_HARNESS_RUNNER" >/dev/null 2>&1 && [[ ! -x "$ACP_HARNESS_RUNNER" ]]; then
    echo "ACP_HARNESS_RUNNER is not executable: $ACP_HARNESS_RUNNER" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$report_path")"

  "$ACP_HARNESS_RUNNER" \
    --contract "$CONTRACT_PATH" \
    --profile "$profile_path" \
    --request "$request_path" \
    --report "$report_path"

  jq -e . "$report_path" >/dev/null
  echo "run: external report written to $report_path"
}

run_reference() {
  local profile_path="$1"
  local request_path="$2"
  local report_path="$3"

  require_cmd python3

  if ! PYTHONPATH="$(pythonpath_with_local_deps)" python3 -c 'import jsonschema, yaml' >/dev/null 2>&1; then
    echo "Reference mode requires Python dependencies from requirements-conformance.txt" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$report_path")"

  PYTHONPATH="$(pythonpath_with_local_deps)" python3 "$ROOT_DIR/scripts/reference_harness.py" \
    --contract "$CONTRACT_PATH" \
    --profile "$profile_path" \
    --request "$request_path" \
    --report "$report_path"

  jq -e . "$report_path" >/dev/null
  echo "run: reference report written to $report_path"
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  local cmd="$1"
  shift

  local profile_rel="$DEFAULT_PROFILE"
  local request_path="$OUT_DIR/run-request.phase1.json"
  local report_path="$OUT_DIR/report.phase1.json"
  local mock_mode="false"
  local reference_mode="false"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        [[ $# -gt 0 ]] || { echo "--profile requires a value" >&2; exit 1; }
        profile_rel="$1"
        ;;
      --request)
        shift
        [[ $# -gt 0 ]] || { echo "--request requires a value" >&2; exit 1; }
        request_path="$1"
        ;;
      --report)
        shift
        [[ $# -gt 0 ]] || { echo "--report requires a value" >&2; exit 1; }
        report_path="$1"
        ;;
      --mock)
        mock_mode="true"
        ;;
      --reference)
        reference_mode="true"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done

  local profile_path
  profile_path="$(resolve_profile "$profile_rel")"

  case "$cmd" in
    doctor)
      doctor "$profile_path"
      ;;
    prepare)
      doctor "$profile_path"
      prepare_request "$profile_path" "$request_path"
      ;;
    run)
      doctor "$profile_path"
      prepare_request "$profile_path" "$request_path"
      if [[ "$mock_mode" == "true" ]]; then
        run_mock "$profile_path" "$report_path"
      elif [[ "$reference_mode" == "true" ]]; then
        run_reference "$profile_path" "$request_path" "$report_path"
      else
        run_external "$profile_path" "$request_path" "$report_path"
      fi
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
