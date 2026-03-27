"""Minimal CLI for ACP SDK workflows."""

from __future__ import annotations

import argparse
import difflib
import json
import sys
from pathlib import Path
from typing import Any

from .reports import report_mismatches, report_summary


def _load_json_input(value: str) -> Any:
    if value == "-":
        return json.loads(sys.stdin.read())
    path = Path(value)
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return json.loads(value)


def _cmd_validate(args: argparse.Namespace) -> int:
    try:
        from .validation import validate_artifact
    except ModuleNotFoundError as exc:
        print(f"missing dependency for validate command: {exc}", file=sys.stderr)
        print("install dependencies: python3 -m pip install -e sdk/python", file=sys.stderr)
        return 2

    errors = validate_artifact(args.artifact, args.schema, args.repo_root)
    if args.output == "json":
        print(json.dumps({"ok": not errors, "errors": errors}, ensure_ascii=False, indent=2))
    else:
        if errors:
            for error in errors:
                print(error)
        else:
            print("valid")
    return 0 if not errors else 1


def _cmd_report_summary(args: argparse.Namespace) -> int:
    print(json.dumps(report_summary(args.report), ensure_ascii=False, indent=2))
    return 0


def _cmd_report_mismatches(args: argparse.Namespace) -> int:
    print(json.dumps(report_mismatches(args.report), ensure_ascii=False, indent=2))
    return 0


def _cmd_diff(args: argparse.Namespace) -> int:
    left = _load_json_input(args.left)
    right = _load_json_input(args.right)
    left_lines = json.dumps(left, ensure_ascii=False, indent=2, sort_keys=True).splitlines(keepends=True)
    right_lines = json.dumps(right, ensure_ascii=False, indent=2, sort_keys=True).splitlines(keepends=True)
    diff_lines = list(
        difflib.unified_diff(
            left_lines,
            right_lines,
            fromfile=args.left,
            tofile=args.right,
        )
    )
    if diff_lines:
        sys.stdout.write("".join(diff_lines))
        return 1
    print("no differences")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="acp", description="ACP validation and reporting CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    validate = subparsers.add_parser("validate", help="Validate artifact against a schema")
    validate.add_argument("--schema", required=True, help="Schema key (e.g. agreement, revision, event)")
    validate.add_argument("--artifact", required=True, help="Artifact JSON file path or inline JSON string")
    validate.add_argument("--repo-root", default=".", help="Repository root containing schemas/")
    validate.add_argument("--output", choices=("text", "json"), default="text")
    validate.set_defaults(handler=_cmd_validate)

    report = subparsers.add_parser("report", help="Report inspection commands")
    report_subparsers = report.add_subparsers(dest="report_command", required=True)

    report_summary_parser = report_subparsers.add_parser("summary", help="Show flattened report summary")
    report_summary_parser.add_argument("--report", required=True, help="Report JSON file path or inline JSON string")
    report_summary_parser.set_defaults(handler=_cmd_report_summary)

    report_mismatch_parser = report_subparsers.add_parser("mismatches", help="Show mismatch entries")
    report_mismatch_parser.add_argument("--report", required=True, help="Report JSON file path or inline JSON string")
    report_mismatch_parser.set_defaults(handler=_cmd_report_mismatches)

    diff_parser = subparsers.add_parser("diff", help="Show unified diff between two JSON payloads")
    diff_parser.add_argument("--left", required=True, help="Left JSON file path, '-' for stdin, or inline JSON")
    diff_parser.add_argument("--right", required=True, help="Right JSON file path or inline JSON")
    diff_parser.set_defaults(handler=_cmd_diff)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.handler(args))


if __name__ == "__main__":
    raise SystemExit(main())
