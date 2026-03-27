#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON="${PYTHON:-python3}"

if ! command -v "$PYTHON" >/dev/null 2>&1; then
  echo "Missing required command: $PYTHON" >&2
  exit 1
fi

PY_TAG="$("$PYTHON" - <<'PY'
import sys
print(f"py{sys.version_info.major}{sys.version_info.minor}")
PY
)"
LOCAL_DEPS="$ROOT_DIR/.tmp/conformance-deps-$PY_TAG"
if [[ -d "$LOCAL_DEPS" ]]; then
  export PYTHONPATH="$LOCAL_DEPS${PYTHONPATH:+:$PYTHONPATH}"
fi

"$PYTHON" - "$ROOT_DIR" "$@" <<'PY'
from __future__ import annotations

import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
requested = [Path(arg) for arg in sys.argv[2:]] or [root / "examples"]

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None

try:
    from jsonschema import Draft202012Validator  # type: ignore
except ImportError:
    Draft202012Validator = None

schema_paths: dict[str, Path] = {}
for schema_dir in (root / "schemas" / "core", root / "schemas" / "companion"):
    if schema_dir.is_dir():
        for schema_path in schema_dir.glob("*_v1.schema.json"):
            schema_paths[schema_path.stem.removesuffix(".schema").removesuffix("_v1")] = schema_path

schema_cache: dict[Path, object] = {}
if Draft202012Validator is not None:
    for schema_path in schema_paths.values():
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        Draft202012Validator.check_schema(schema)
        schema_cache[schema_path] = Draft202012Validator(schema)

files: list[Path] = []
for target in requested:
    target_path = target if target.is_absolute() else root / target
    if not target_path.exists():
        raise SystemExit(f"Missing target: {target_path}")
    if target_path.is_file():
        files.append(target_path)
    else:
        files.extend(
            path
            for path in sorted(target_path.rglob("*"))
            if path.is_file() and path.suffix.lower() in {".yaml", ".yml", ".json"}
        )

if not files:
    print("validate-examples: no YAML/JSON files found")
    raise SystemExit(0)

schema_validation = Draft202012Validator is not None
if not schema_validation:
    print("validate-examples: schema validation skipped (missing python deps)", file=sys.stderr)

validated = 0
for path in files:
    if (
        path.is_relative_to(root / "examples" / "integrations")
        and path.name in {"config.example.json", "sample_request.json"}
    ):
        print(f"{path.relative_to(root)}: skipped (non-artifact integration helper)")
        continue

    text = path.read_text(encoding="utf-8")
    if path.suffix.lower() in {".yaml", ".yml"}:
        if yaml is None:
            raise SystemExit(f"{path}: YAML parsing requires PyYAML")
        data = yaml.safe_load(text)
    else:
        data = json.loads(text)

    if not isinstance(data, dict):
        raise SystemExit(f"{path}: top-level payload must be a mapping")

    artifact_type = data.get("artifact_type")
    binding_type = data.get("binding_type")
    schema_id = artifact_type or binding_type
    if not isinstance(schema_id, str) or not schema_id.endswith("_v1"):
        raise SystemExit(f"{path}: missing or invalid artifact_type/binding_type")

    logical_type = schema_id.removesuffix("_v1")
    schema_path = schema_paths.get(logical_type)
    if schema_path is None:
        raise SystemExit(f"{path}: no schema mapping for {schema_id}")

    if schema_validation:
        validator = schema_cache[schema_path]
        errors = sorted(validator.iter_errors(data), key=lambda item: list(item.path))
        if errors:
            message = "; ".join(error.message for error in errors[:3])
            raise SystemExit(f"{path}: schema validation failed: {message}")

    validated += 1
    print(f"{path.relative_to(root)}: ok")

print(f"validate-examples: ok ({validated} file(s))")
PY
