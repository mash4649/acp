#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CI_SCRIPT="$ROOT_DIR/scripts/conformance_ci.sh"
MOCK_RUNNER="$ROOT_DIR/scripts/mock_external_runner.sh"
OUT_DIR="$ROOT_DIR/conformance/out"

python_tag() {
  python3 - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
}

CONFORMANCE_PYTHONPATH="$ROOT_DIR/.tmp/conformance-deps-$(python_tag)"

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

main() {
  require_cmd jq

  [[ -x "$CI_SCRIPT" ]] || { echo "Missing executable: $CI_SCRIPT" >&2; exit 1; }
  [[ -x "$MOCK_RUNNER" ]] || { echo "Missing executable: $MOCK_RUNNER" >&2; exit 1; }

  if [[ "${ACP_AUTO_INSTALL_CONFORMANCE_DEPS:-}" == "1" ]]; then
    "$ROOT_DIR/scripts/install_conformance_deps.sh"
  fi

  if ! PYTHONPATH="$(pythonpath_with_local_deps)" python3 -c 'import jsonschema, yaml' >/dev/null 2>&1; then
    echo "Skipping reference selftests because Python conformance dependencies are not installed." >&2
    echo "Run: ./scripts/install_conformance_deps.sh" >&2
    exit 1
  fi

  echo "[1/7] conformance CI in mock mode"
  ACP_CONFORMANCE_MODE=mock "$CI_SCRIPT"

  echo "[2/7] conformance CI in reference mode (phase1)"
  ACP_CONFORMANCE_MODE=reference "$CI_SCRIPT"

  echo "[3/7] conformance CI in reference mode (phase2)"
  ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE="conformance/profiles/phase2.profile.json" "$CI_SCRIPT"

  echo "[4/7] conformance CI in reference mode (phase3)"
  ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE="conformance/profiles/phase3.profile.json" "$CI_SCRIPT"

  echo "[5/7] contract smoke with external mode and mock runner"
  ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER="$MOCK_RUNNER" "$CI_SCRIPT"

  echo "[6/7] negative-path check (required-external must reject mock runner)"
  if ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER="$MOCK_RUNNER" "$CI_SCRIPT" >/tmp/acp-selftest-negative.out 2>&1; then
    echo "Expected required-external failure did not occur." >&2
    cat /tmp/acp-selftest-negative.out >&2
    exit 1
  fi
  echo "negative-path: expected failure observed"

  local bundled_runner="$ROOT_DIR/scripts/acp_harness_runner.sh"
  rm -rf "$OUT_DIR/parity-selftest"
  echo "[7/7] parity suite (reference vs bundled runner, phase3; expect zero diff)"
  ACP_PARITY_MODE=reference-external \
    ACP_CONFORMANCE_PROFILE="conformance/profiles/phase3.profile.json" \
    ACP_HARNESS_RUNNER="$bundled_runner" \
    ACP_PARITY_OUT_DIR="$OUT_DIR/parity-selftest" \
    "$ROOT_DIR/scripts/conformance_parity.sh"

  rm -rf "$OUT_DIR/parity-selftest"
  rm -f "$OUT_DIR/run-request.phase1.json" "$OUT_DIR/report.phase1.json" /tmp/acp-selftest-negative.out
  echo "selftest: ok"
}

main "$@"
