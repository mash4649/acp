#!/usr/bin/env bash
set -euo pipefail

# Compare two conformance reports (reference vs external, or external vs external).
# Writes conformance/out/parity/parity-report.<profile_id>.json and exits non-zero on mismatch.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CI_SCRIPT="$ROOT_DIR/scripts/conformance_ci.sh"
OUT_BASE="${ACP_PARITY_OUT_DIR:-$ROOT_DIR/conformance/out/parity}"
MODE="${ACP_PARITY_MODE:-reference-external}"
PROFILE="${ACP_CONFORMANCE_PROFILE:-conformance/profiles/phase3.profile.json}"

usage() {
  cat <<'EOF'
Usage:
  ACP_CONFORMANCE_PROFILE=<profile> ACP_HARNESS_RUNNER=<runner> ./scripts/conformance_parity.sh

Modes (ACP_PARITY_MODE):
  reference-external   Generate reference report + required-external report (default).
                       Requires ACP_HARNESS_RUNNER.
  runner-runner        Generate two required-external reports.
                       Requires ACP_HARNESS_RUNNER and ACP_HARNESS_RUNNER_2.
  compare-only         Compare existing reports (no generation).
                       Requires ACP_PARITY_LEFT_REPORT and ACP_PARITY_RIGHT_REPORT.

Optional:
  ACP_PARITY_OUT_DIR       Output directory (default: conformance/out/parity)
  ACP_PARITY_LEFT_LABEL    Label for left side in JSON (default: depends on mode)
  ACP_PARITY_RIGHT_LABEL   Label for right side in JSON

Exit code 0 only when top-level status/summary.failed match and every result verdict matches
for the same target_id set.

Note: Bundled ./scripts/acp_harness_runner.sh invokes the same reference harness; diff against
reference should be empty. Use production runners in ACP_HARNESS_RUNNER for meaningful deltas.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

slugify_profile() {
  local base
  base="$(basename "$PROFILE" .json)"
  printf '%s' "${base//\//_}"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_cmd jq
  local slug
  slug="$(slugify_profile)"
  mkdir -p "$OUT_BASE"
  local ts
  ts="$(date -u +"%Y%m%dT%H%M%SZ")"
  local left_report right_report
  local left_label right_label

  case "$MODE" in
    reference-external)
      [[ -n "${ACP_HARNESS_RUNNER:-}" ]] || { echo "ACP_HARNESS_RUNNER is required." >&2; exit 1; }
      left_report="$OUT_BASE/report.reference.${slug}.${ts}.json"
      right_report="$OUT_BASE/report.external.${slug}.${ts}.json"
      left_label="${ACP_PARITY_LEFT_LABEL:-reference}"
      right_label="${ACP_PARITY_RIGHT_LABEL:-external ($ACP_HARNESS_RUNNER)}"
      ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE="$PROFILE" ACP_CONFORMANCE_REPORT="$left_report" "$CI_SCRIPT"
      ACP_CONFORMANCE_MODE=required-external ACP_CONFORMANCE_PROFILE="$PROFILE" ACP_CONFORMANCE_REPORT="$right_report" ACP_HARNESS_RUNNER="${ACP_HARNESS_RUNNER}" "$CI_SCRIPT"
      ;;
    runner-runner)
      [[ -n "${ACP_HARNESS_RUNNER:-}" && -n "${ACP_HARNESS_RUNNER_2:-}" ]] || {
        echo "ACP_HARNESS_RUNNER and ACP_HARNESS_RUNNER_2 are required." >&2
        exit 1
      }
      left_report="$OUT_BASE/report.runner1.${slug}.${ts}.json"
      right_report="$OUT_BASE/report.runner2.${slug}.${ts}.json"
      left_label="${ACP_PARITY_LEFT_LABEL:-runner1 ($ACP_HARNESS_RUNNER)}"
      right_label="${ACP_PARITY_RIGHT_LABEL:-runner2 ($ACP_HARNESS_RUNNER_2)}"
      ACP_CONFORMANCE_MODE=required-external ACP_CONFORMANCE_PROFILE="$PROFILE" ACP_CONFORMANCE_REPORT="$left_report" ACP_HARNESS_RUNNER="${ACP_HARNESS_RUNNER}" "$CI_SCRIPT"
      ACP_CONFORMANCE_MODE=required-external ACP_CONFORMANCE_PROFILE="$PROFILE" ACP_CONFORMANCE_REPORT="$right_report" ACP_HARNESS_RUNNER="${ACP_HARNESS_RUNNER_2}" "$CI_SCRIPT"
      ;;
    compare-only)
      left_report="${ACP_PARITY_LEFT_REPORT:-}"
      right_report="${ACP_PARITY_RIGHT_REPORT:-}"
      [[ -n "$left_report" && -n "$right_report" ]] || {
        echo "ACP_PARITY_LEFT_REPORT and ACP_PARITY_RIGHT_REPORT are required." >&2
        exit 1
      }
      [[ -f "$left_report" && -f "$right_report" ]] || {
        echo "Report files must exist." >&2
        exit 1
      }
      left_label="${ACP_PARITY_LEFT_LABEL:-left}"
      right_label="${ACP_PARITY_RIGHT_LABEL:-right}"
      ;;
    *)
      echo "Unknown ACP_PARITY_MODE: $MODE" >&2
      exit 1
      ;;
  esac

  local parity_out="$OUT_BASE/parity-report.${slug}.json"
  local tmp_combined
  tmp_combined="$(mktemp)"
  jq -n \
    --arg mode "$MODE" \
    --arg profile_cfg "$PROFILE" \
    --arg left_path "$left_report" \
    --arg right_path "$right_report" \
    --arg left_l "$left_label" \
    --arg right_l "$right_label" \
    --slurpfile L "$left_report" \
    --slurpfile R "$right_report" \
    '
    ($L[0]) as $l
    | ($R[0]) as $r
    | ($l.results | map({(.target_id): .verdict}) | add // {}) as $lv
    | ($r.results | map({(.target_id): .verdict}) | add // {}) as $rv
    | (($lv | keys_unsorted) + ($rv | keys_unsorted) | unique) as $all
    | ($all | map(select(($lv[.] // "") != ($rv[.] // "")))) as $verdict_mismatches_objs
    | ($all | map(select($lv[.] == null))) as $right_only
    | ($all | map(select($rv[.] == null))) as $left_only
    | ($verdict_mismatches_objs | map({target_id: ., left: $lv[.], right: $rv[.]})) as $verdict_mismatches
    | ($l.profile_id == $r.profile_id) as $profile_match
    | ($l.status == $r.status) as $status_match
    | (($l.summary.failed // -1) == ($r.summary.failed // -2)) as $failed_match
    | (($l.summary.passed // -1) == ($r.summary.passed // -2)) as $passed_match
    | (($l.summary.total // -1) == ($r.summary.total // -2)) as $total_match
    | (($verdict_mismatches | length) == 0 and ($left_only | length) == 0 and ($right_only | length) == 0
        and $profile_match and $status_match and $failed_match and $passed_match and $total_match) as $parity_pass
    | {
        generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        parity_mode: $mode,
        profile_path: $profile_cfg,
        profile_id_left: $l.profile_id,
        profile_id_right: $r.profile_id,
        left: { label: $left_l, report_path: $left_path, status: $l.status, summary: $l.summary },
        right: { label: $right_l, report_path: $right_path, status: $r.status, summary: $r.summary },
        top_level_match: {
          profile_id: $profile_match,
          status: $status_match,
          summary_failed: $failed_match,
          summary_passed: $passed_match,
          summary_total: $total_match
        },
        results_diff: {
          verdict_mismatches: $verdict_mismatches,
          target_ids_left_only: $left_only,
          target_ids_right_only: $right_only
        },
        parity_pass: $parity_pass
      }
    ' >"$tmp_combined"

  mv "$tmp_combined" "$parity_out"
  if [[ "$(jq -r '.parity_pass' "$parity_out")" != "true" ]]; then
    echo "conformance_parity: FAIL (see $parity_out)" >&2
    jq '.top_level_match, .results_diff' "$parity_out" >&2
    exit 1
  fi
  echo "conformance_parity: ok -> $parity_out"
}

main "$@"
