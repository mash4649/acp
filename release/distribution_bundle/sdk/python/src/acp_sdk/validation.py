"""Schema resolution and artifact validation helpers."""

from __future__ import annotations

import json
from collections.abc import Mapping
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator


def _read_json(source: Any) -> Any:
    if isinstance(source, Mapping):
        return dict(source)
    path = Path(source)
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    if isinstance(source, str):
        text = source.lstrip()
        if text.startswith("{") or text.startswith("["):
            return json.loads(source)
    raise FileNotFoundError(f"artifact not found: {source}")


def _schema_map(source: Any) -> dict[str, Path] | None:
    if not isinstance(source, Mapping):
        return None
    maybe_map = source.get("schema_map") if isinstance(source.get("schema_map"), Mapping) else source
    if not isinstance(maybe_map, Mapping):
        return None
    if not maybe_map:
        return {}
    if all(isinstance(value, (str, Path)) for value in maybe_map.values()):
        return {str(key): Path(value) for key, value in maybe_map.items()}
    return None


def _resolve_schema_path(schema_key: str, repo_root_or_schema_map: Any) -> Path:
    schema_map = _schema_map(repo_root_or_schema_map)
    if schema_map is not None:
        schema_path = schema_map.get(schema_key)
        if schema_path is None:
            raise KeyError(schema_key)
        return schema_path

    repo_root = Path(repo_root_or_schema_map)
    candidates = (
        repo_root / "schemas" / "core" / f"{schema_key}_v1.schema.json",
        repo_root / "schemas" / "companion" / f"{schema_key}_v1.schema.json",
        repo_root / "schemas" / f"{schema_key}_v1.schema.json",
    )
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError(f"schema not found for {schema_key}")


def _format_error(error: Any) -> str:
    location = "$"
    if error.path:
        location = "$." + ".".join(str(part) for part in error.path)
    return f"{location}: {error.message}"


def validate_artifact(
    payload_or_path: Any,
    schema_key: str,
    repo_root_or_schema_map: Any,
) -> list[str]:
    """Validate a payload against a repo-local ACP schema.

    Returns a list of human-readable validation errors. An empty list means the
    payload matched the schema.
    """

    payload = _read_json(payload_or_path)
    try:
        schema_path = _resolve_schema_path(schema_key, repo_root_or_schema_map)
    except (FileNotFoundError, KeyError) as exc:
        return [str(exc)]

    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    validator = Draft202012Validator(schema)
    errors = sorted(
        validator.iter_errors(payload),
        key=lambda error: (list(error.path), error.message),
    )
    return [_format_error(error) for error in errors]
