"""Helpers for parsing conformance reports."""

from __future__ import annotations

import json
from collections.abc import Mapping
from pathlib import Path
from typing import Any


def _load_report(report_or_path: Any) -> dict[str, Any]:
    if isinstance(report_or_path, Mapping):
        return dict(report_or_path)
    path = Path(report_or_path)
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    if isinstance(report_or_path, str):
        text = report_or_path.lstrip()
        if text.startswith("{") or text.startswith("["):
            return json.loads(report_or_path)
    raise FileNotFoundError(f"report not found: {report_or_path}")


def parse_report(report_or_path: Any) -> dict[str, Any]:
    """Return the parsed report payload."""

    return _load_report(report_or_path)


def report_summary(report_or_path: Any) -> dict[str, Any]:
    """Return a flattened summary for quick inspection."""

    report = _load_report(report_or_path)
    summary = dict(report.get("summary", {}))
    summary.update(
        {
            "run_id": report.get("run_id"),
            "profile_id": report.get("profile_id"),
            "status": report.get("status"),
            "generated_at": report.get("generated_at"),
        }
    )
    return summary


def report_mismatches(report_or_path: Any) -> list[dict[str, Any]]:
    """Return the result entries that were marked as mismatches."""

    report = _load_report(report_or_path)
    results = report.get("results", [])
    if not isinstance(results, list):
        return []
    return [dict(result) for result in results if isinstance(result, Mapping) and result.get("verdict") == "mismatch"]
