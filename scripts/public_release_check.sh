#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

check_required_files() {
  local missing=0
  local files=(
    "$ROOT_DIR/README.md"
    "$ROOT_DIR/assets/en/README.txt"
    "$ROOT_DIR/assets/en/00_package_baseline.txt"
    "$ROOT_DIR/assets/en/01_message_map.md"
    "$ROOT_DIR/assets/en/02_launch_copy_bank.md"
    "$ROOT_DIR/assets/en/03_demo_script_90s.md"
    "$ROOT_DIR/assets/en/04_share_faq.md"
    "$ROOT_DIR/assets/en/05_anchor_use_case.txt"
    "$ROOT_DIR/assets/en/06_comparison_matrix_short.txt"
    "$ROOT_DIR/assets/en/07_channel_playbook.md"
    "$ROOT_DIR/assets/en/08_demo_script_30s.md"
    "$ROOT_DIR/assets/en/09_demo_script_3min.md"
    "$ROOT_DIR/assets/en/10_schema_release_plan.md"
    "$ROOT_DIR/assets/en/11_faq_top5.md"
    "$ROOT_DIR/assets/en/12_readme_repo_ready.md"
    "$ROOT_DIR/assets/en/13_objection_memo.md"
    "$ROOT_DIR/assets/en/14_issue_submission_packet.md"
  )

  for f in "${files[@]}"; do
    if [[ ! -f "$f" ]]; then
      echo "Missing required public file: $f" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

check_required_phrases() {
  local target="$ROOT_DIR/README.md"
  local required=(
    "ACP is an accountability layer for delegated AI work."
    "not an execution framework"
    "not a transport protocol"
    "not a payment rail"
    "Prompt is not contract."
    "Claim is not evidence."
    "Verification is not settlement."
  )

  for phrase in "${required[@]}"; do
    if ! rg -Fq "$phrase" "$target"; then
      echo "Missing required phrase in README: $phrase" >&2
      exit 1
    fi
  done
}

check_banned_phrases() {
  local scope=("$ROOT_DIR/README.md" "$ROOT_DIR/assets")
  local banned=(
    "another general AI agent protocol"
    "ACP is an execution framework"
    "ACP is a transport protocol"
    "ACP is a payment rail"
    "prompt is contract"
    "claim is evidence"
    "verification is settlement"
  )

  for phrase in "${banned[@]}"; do
    if rg -n -i -g '!schema_templates/**' -e "$phrase" "${scope[@]}" >/dev/null; then
      echo "Banned phrase detected: $phrase" >&2
      rg -n -i -g '!schema_templates/**' -e "$phrase" "${scope[@]}" || true
      exit 1
    fi
  done
}

main() {
  require_cmd rg
  check_required_files
  check_required_phrases
  check_banned_phrases
  echo "public-release-check: ok"
}

main "$@"
