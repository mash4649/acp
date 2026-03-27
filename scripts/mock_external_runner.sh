#!/usr/bin/env bash
set -euo pipefail

CONTRACT_PATH=""
PROFILE_PATH=""
REQUEST_PATH=""
REPORT_PATH=""

usage() {
  cat <<USAGE
Usage:
  ./scripts/mock_external_runner.sh \
    --contract <path> \
    --profile <path> \
    --request <path> \
    --report <path>

Environment:
  MOCK_EXTERNAL_FAIL=1  Force one mismatch to simulate external failure.
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

schema_key_for_vector() {
  local vector_path="$1"
  local base
  base="$(basename "$vector_path")"

  case "$base" in
    agreement_*) echo "agreement" ;;
    revision_*) echo "revision" ;;
    event_*) echo "event" ;;
    evidence_*) echo "evidence_pack" ;;
    verification_*) echo "verification_report" ;;
    settlement_*) echo "settlement_intent" ;;
    freeze_*) echo "freeze_record" ;;
    *)
      echo "unknown"
      return 1
      ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --contract)
        shift
        [[ $# -gt 0 ]] || { echo "--contract requires a value" >&2; exit 1; }
        CONTRACT_PATH="$1"
        ;;
      --profile)
        shift
        [[ $# -gt 0 ]] || { echo "--profile requires a value" >&2; exit 1; }
        PROFILE_PATH="$1"
        ;;
      --request)
        shift
        [[ $# -gt 0 ]] || { echo "--request requires a value" >&2; exit 1; }
        REQUEST_PATH="$1"
        ;;
      --report)
        shift
        [[ $# -gt 0 ]] || { echo "--report requires a value" >&2; exit 1; }
        REPORT_PATH="$1"
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
}

main() {
  parse_args "$@"
  require_cmd jq

  [[ -n "$CONTRACT_PATH" && -f "$CONTRACT_PATH" ]] || { echo "Missing contract path" >&2; exit 1; }
  [[ -n "$PROFILE_PATH" && -f "$PROFILE_PATH" ]] || { echo "Missing profile path" >&2; exit 1; }
  [[ -n "$REQUEST_PATH" && -f "$REQUEST_PATH" ]] || { echo "Missing request path" >&2; exit 1; }
  [[ -n "$REPORT_PATH" ]] || { echo "Missing report path" >&2; exit 1; }

  local profile_id run_id now force_fail
  profile_id="$(jq -r '.profile_id' "$PROFILE_PATH")"
  run_id="external-mock-$(date -u +"%Y%m%d%H%M%S")"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  force_fail="${MOCK_EXTERNAL_FAIL:-0}"

  local tmp_dir expected_results fail_results valid_list invalid_list
  tmp_dir="$(mktemp -d)"
  expected_results="$tmp_dir/results.jsonl"
  fail_results="$tmp_dir/results.fail.jsonl"
  : > "$expected_results"

  valid_list="$(mktemp)"
  invalid_list="$(mktemp)"
  jq -r '.vectors.valid[]' "$PROFILE_PATH" > "$valid_list"
  jq -r '.vectors.invalid[]' "$PROFILE_PATH" > "$invalid_list"

  while IFS= read -r vec; do
    local key schema_path expected actual verdict
    key="$(schema_key_for_vector "$vec")"
    schema_path="$(jq -r --arg k "$key" '.schema_map[$k]' "$PROFILE_PATH")"
    expected="pass"
    actual="pass"
    verdict="match"
    jq -cn \
      --arg vector_path "$vec" \
      --arg schema_path "$schema_path" \
      --arg expected "$expected" \
      --arg actual "$actual" \
      --arg verdict "$verdict" \
      '{vector_path:$vector_path,schema_path:$schema_path,expected:$expected,actual:$actual,verdict:$verdict}' \
      >> "$expected_results"
  done < "$valid_list"

  while IFS= read -r vec; do
    local key schema_path expected actual verdict
    key="$(schema_key_for_vector "$vec")"
    schema_path="$(jq -r --arg k "$key" '.schema_map[$k]' "$PROFILE_PATH")"
    expected="fail"
    actual="fail"
    verdict="match"
    jq -cn \
      --arg vector_path "$vec" \
      --arg schema_path "$schema_path" \
      --arg expected "$expected" \
      --arg actual "$actual" \
      --arg verdict "$verdict" \
      '{vector_path:$vector_path,schema_path:$schema_path,expected:$expected,actual:$actual,verdict:$verdict}' \
      >> "$expected_results"
  done < "$invalid_list"

  if [[ "$force_fail" == "1" ]]; then
    awk 'NR==1{sub(/"verdict":"match"/,"\"verdict\":\"mismatch\""); sub(/"actual":"pass"/,"\"actual\":\"fail\"")}1' \
      "$expected_results" > "$fail_results"
    mv "$fail_results" "$expected_results"
  fi

  local total failed passed status notes
  total="$(wc -l < "$expected_results" | tr -d ' ')"
  failed="$(jq -sc '[.[] | select(.verdict=="mismatch")] | length' "$expected_results")"
  passed="$((total - failed))"
  status="pass"
  notes='["Mock external runner report (contract integration test only)."]'
  if [[ "$failed" != "0" ]]; then
    status="fail"
    notes='["Mock external runner forced mismatch for negative-path testing."]'
  fi

  mkdir -p "$(dirname "$REPORT_PATH")"

  jq -n \
    --arg run_id "$run_id" \
    --arg profile_id "$profile_id" \
    --arg generated_at "$now" \
    --arg status "$status" \
    --argjson total "$total" \
    --argjson passed "$passed" \
    --argjson failed "$failed" \
    --argjson notes "$notes" \
    --slurpfile results "$expected_results" \
    '{
      run_id: $run_id,
      profile_id: $profile_id,
      status: $status,
      generated_at: $generated_at,
      summary: {
        total: $total,
        passed: $passed,
        failed: $failed,
        notes: $notes
      },
      results: $results
    }' > "$REPORT_PATH"

  rm -f "$valid_list" "$invalid_list"
  rm -rf "$tmp_dir"
}

main "$@"
