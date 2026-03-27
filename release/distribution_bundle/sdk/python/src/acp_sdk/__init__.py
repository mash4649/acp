"""Minimal ACP Python SDK."""

from __future__ import annotations

from typing import Any

from .artifacts import build_agreement, build_event, build_revision
from .reports import parse_report, report_mismatches, report_summary

__all__ = [
    "build_agreement",
    "build_event",
    "build_revision",
    "parse_report",
    "report_mismatches",
    "report_summary",
    "validate_artifact",
]

__version__ = "0.1.0"


def validate_artifact(
    payload_or_path: Any,
    schema_key: str,
    repo_root_or_schema_map: Any,
) -> list[str]:
    """Validate an artifact payload against the named schema.

    The implementation is imported lazily so report parsing and builders
    remain usable even in environments that only need the lightweight API.
    """

    from .validation import validate_artifact as _validate_artifact

    return _validate_artifact(payload_or_path, schema_key, repo_root_or_schema_map)
