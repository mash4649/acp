#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_PATH="$ROOT_DIR/conformance/report.schema.json"
FIXTURE_DIR="$ROOT_DIR/conformance/compat/v1"
OUT_DIR="$ROOT_DIR/conformance/out"
INCLUDE_OUT=0

python_tag() {
  python3 - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
}

CONFORMANCE_PYTHONPATH="$ROOT_DIR/.tmp/conformance-deps-$(python_tag)"

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
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --include-out)
        INCLUDE_OUT=1
        shift
        ;;
      *)
        echo "Unknown argument: $1" >&2
        exit 1
        ;;
    esac
  done

  if ! PYTHONPATH="$(pythonpath_with_local_deps)" python3 -c 'import jsonschema' >/dev/null 2>&1; then
    echo "Missing jsonschema dependency. Run: ./scripts/install_conformance_deps.sh" >&2
    exit 1
  fi

  if [[ ! -f "$SCHEMA_PATH" ]]; then
    echo "Missing schema: $SCHEMA_PATH" >&2
    exit 1
  fi

  if [[ ! -d "$FIXTURE_DIR" ]]; then
    echo "Missing compatibility fixtures: $FIXTURE_DIR" >&2
    exit 1
  fi

  PYTHONPATH="$(pythonpath_with_local_deps)" python3 - "$SCHEMA_PATH" "$FIXTURE_DIR" "$OUT_DIR" "$INCLUDE_OUT" <<'PY'
import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator, FormatChecker

schema_path = Path(sys.argv[1])
fixture_dir = Path(sys.argv[2])
out_dir = Path(sys.argv[3])
include_out = sys.argv[4] == "1"

schema = json.loads(schema_path.read_text(encoding="utf-8"))
validator = Draft202012Validator(schema, format_checker=FormatChecker())

required_top = {"run_id", "profile_id", "status", "generated_at", "summary", "results"}
required_result = {"vector_path", "schema_path", "expected", "actual", "verdict"}

reports = sorted(fixture_dir.glob("*.json"))
if include_out:
    reports.extend(sorted(out_dir.glob("report*.json")))
if not reports:
    raise SystemExit("No compatibility reports found.")

seen = set()
validated = 0
for report_path in reports:
    report_path = report_path.resolve()
    if report_path in seen:
        continue
    seen.add(report_path)

    payload = json.loads(report_path.read_text(encoding="utf-8"))
    errors = sorted(validator.iter_errors(payload), key=lambda err: list(err.absolute_path))
    if errors:
        first = errors[0]
        location = "/".join(map(str, first.absolute_path)) or "<root>"
        raise SystemExit(f"schema validation failed: {report_path}: {location}: {first.message}")

    missing_top = sorted(required_top.difference(payload))
    if missing_top:
        raise SystemExit(f"compatibility contract failed: {report_path}: missing top-level keys: {', '.join(missing_top)}")

    if not isinstance(payload.get("results"), list):
        raise SystemExit(f"compatibility contract failed: {report_path}: results must be an array")

    for index, result in enumerate(payload["results"]):
        if not isinstance(result, dict):
            raise SystemExit(f"compatibility contract failed: {report_path}: results[{index}] must be an object")
        missing_result = sorted(required_result.difference(result))
        if missing_result:
            raise SystemExit(
                f"compatibility contract failed: {report_path}: results[{index}] missing keys: {', '.join(missing_result)}"
            )

    validated += 1

print(f"cross-version-compat: ok ({validated} report(s))")
PY
}

main "$@"
