#!/usr/bin/env bash
set -euo pipefail

# Bundled non-mock ACP_HARNESS_RUNNER for this public_bundle.
# Satisfies harness_contract_v1.json CLI (--contract --profile --request --report).
# Invokes reference_harness.py with versioned deps under .tmp/conformance-deps-pyXY.
# This is the contract-compliant adapter used for required-external evidence (not the mock runner).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REFERENCE_HARNESS="$ROOT_DIR/scripts/reference_harness.py"

python_tag() {
  python3 - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
}

CONFORMANCE_PYTHONPATH="$ROOT_DIR/.tmp/conformance-deps-$(python_tag)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/acp_harness_runner.sh \
    --contract <path> \
    --profile <path> \
    --request <path> \
    --report <path>
EOF
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

main() {
  local contract=""
  local profile=""
  local request=""
  local report=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --contract)
        shift
        [[ $# -gt 0 ]] || { echo "--contract requires a value" >&2; exit 2; }
        contract="$1"
        ;;
      --profile)
        shift
        [[ $# -gt 0 ]] || { echo "--profile requires a value" >&2; exit 2; }
        profile="$1"
        ;;
      --request)
        shift
        [[ $# -gt 0 ]] || { echo "--request requires a value" >&2; exit 2; }
        request="$1"
        ;;
      --report)
        shift
        [[ $# -gt 0 ]] || { echo "--report requires a value" >&2; exit 2; }
        report="$1"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 2
        ;;
    esac
    shift
  done

  [[ -n "$contract" ]] || { echo "Missing required arg: --contract" >&2; exit 2; }
  [[ -n "$profile" ]] || { echo "Missing required arg: --profile" >&2; exit 2; }
  [[ -n "$request" ]] || { echo "Missing required arg: --request" >&2; exit 2; }
  [[ -n "$report" ]] || { echo "Missing required arg: --report" >&2; exit 2; }

  [[ -f "$contract" ]] || { echo "Missing contract path: $contract" >&2; exit 2; }
  [[ -f "$profile" ]] || { echo "Missing profile path: $profile" >&2; exit 2; }
  [[ -f "$request" ]] || { echo "Missing request path: $request" >&2; exit 2; }
  [[ -f "$REFERENCE_HARNESS" ]] || { echo "Missing reference harness: $REFERENCE_HARNESS" >&2; exit 2; }

  if ! PYTHONPATH="$(pythonpath_with_local_deps)" python3 -c 'import jsonschema, yaml' >/dev/null 2>&1; then
    echo "Runner dependency check failed. Install: ./scripts/install_conformance_deps.sh" >&2
    exit 3
  fi

  mkdir -p "$(dirname "$report")"

  if ! PYTHONPATH="$(pythonpath_with_local_deps)" python3 "$REFERENCE_HARNESS" \
    --contract "$contract" \
    --profile "$profile" \
    --request "$request" \
    --report "$report"; then
    exit 4
  fi
}

main "$@"
