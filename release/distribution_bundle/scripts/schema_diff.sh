#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FORMAT="markdown"
FAIL_ON_BREAKING=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/schema_diff.sh --old <dir-or-git-ref> --new <dir-or-git-ref> [--format markdown|json] [--fail-on-breaking]

Examples:
  ./scripts/schema_diff.sh --old HEAD~1 --new HEAD
  ./scripts/schema_diff.sh --old /tmp/schemas-old --new /tmp/schemas-new --format json
USAGE
}

die() {
  echo "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

OLD_INPUT=""
NEW_INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --old)
      OLD_INPUT="${2:-}"
      shift 2
      ;;
    --new)
      NEW_INPUT="${2:-}"
      shift 2
      ;;
    --format)
      OUT_FORMAT="${2:-}"
      shift 2
      ;;
    --fail-on-breaking)
      FAIL_ON_BREAKING=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$OLD_INPUT" ]] || die "Missing --old"
[[ -n "$NEW_INPUT" ]] || die "Missing --new"
[[ "$OUT_FORMAT" == "markdown" || "$OUT_FORMAT" == "json" ]] || die "Invalid --format: $OUT_FORMAT"

require_cmd python3

if [[ ! -d "$OLD_INPUT" || ! -d "$NEW_INPUT" ]]; then
  require_cmd git
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

export_tree() {
  local input="$1"
  local out_dir="$2"
  mkdir -p "$out_dir/schemas" "$out_dir/conformance"

  if [[ -d "$input" ]]; then
    [[ -d "$input/schemas" ]] || die "Directory input missing schemas/: $input"
    cp -R "$input/schemas/." "$out_dir/schemas/"
    if [[ -f "$input/conformance/report.schema.json" ]]; then
      cp "$input/conformance/report.schema.json" "$out_dir/conformance/report.schema.json"
    fi
    return
  fi

  local repo_root
  repo_root="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null)" || die "Not a git repository: cannot resolve ref '$input'"
  local files
  files="$(git -C "$repo_root" ls-tree -r --name-only "$input" -- 'schemas/*.json' 'conformance/report.schema.json')" || die "Failed to list files for ref: $input"
  [[ -n "$files" ]] || die "No schema files found for ref: $input"

  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    local target="$out_dir/$rel"
    mkdir -p "$(dirname "$target")"
    git -C "$repo_root" show "$input:$rel" >"$target"
  done <<<"$files"
}

OLD_EXPORT="$TMP_DIR/old"
NEW_EXPORT="$TMP_DIR/new"
export_tree "$OLD_INPUT" "$OLD_EXPORT"
export_tree "$NEW_INPUT" "$NEW_EXPORT"

python3 - "$OLD_EXPORT" "$NEW_EXPORT" "$OUT_FORMAT" "$FAIL_ON_BREAKING" <<'PY'
import json
import sys
from pathlib import Path

old_root = Path(sys.argv[1])
new_root = Path(sys.argv[2])
out_format = sys.argv[3]
fail_on_breaking = sys.argv[4] == "1"

SEVERITY = {"unchanged": 0, "compatible": 1, "review-required": 2, "breaking": 3}
TIGHTEN_MIN_KEYS = {"minimum", "exclusiveMinimum", "minLength", "minItems", "minProperties"}
TIGHTEN_MAX_KEYS = {"maximum", "exclusiveMaximum", "maxLength", "maxItems", "maxProperties"}

def schema_files(root: Path) -> dict[str, Path]:
    files: dict[str, Path] = {}
    for prefix in ("schemas",):
        base = root / prefix
        if base.exists():
            for path in sorted(base.rglob("*.json")):
                files[str(path.relative_to(root))] = path
    report = root / "conformance" / "report.schema.json"
    if report.exists():
        files[str(report.relative_to(root))] = report
    return files

def compare_rules(path: str, old, new, reasons: list[str], ptr: str = ""):
    location = ptr or "/"
    if isinstance(old, dict) and isinstance(new, dict):
        if "required" in old and "required" in new and isinstance(old["required"], list) and isinstance(new["required"], list):
            old_required = set(str(x) for x in old["required"])
            new_required = set(str(x) for x in new["required"])
            removed = sorted(old_required - new_required)
            added = sorted(new_required - old_required)
            if removed:
                reasons.append(f"compatible: {location} removed required {', '.join(removed)}")
            if added:
                reasons.append(f"breaking: {location} added required {', '.join(added)}")

        if "enum" in old and "enum" in new and isinstance(old["enum"], list) and isinstance(new["enum"], list):
            old_enum = set(json.dumps(v, sort_keys=True) for v in old["enum"])
            new_enum = set(json.dumps(v, sort_keys=True) for v in new["enum"])
            removed = sorted(json.loads(v) for v in (old_enum - new_enum))
            added = sorted(json.loads(v) for v in (new_enum - old_enum))
            if removed:
                reasons.append(f"breaking: {location} removed enum values {removed}")
            if added:
                reasons.append(f"compatible: {location} added enum values {added}")

        if "type" in old and "type" in new and old["type"] != new["type"]:
            reasons.append(f"breaking: {location} changed type {old['type']} -> {new['type']}")

        if isinstance(old.get("additionalProperties"), bool) and isinstance(new.get("additionalProperties"), bool):
            if old["additionalProperties"] and not new["additionalProperties"]:
                reasons.append(f"breaking: {location} changed additionalProperties true -> false")
            elif not old["additionalProperties"] and new["additionalProperties"]:
                reasons.append(f"compatible: {location} changed additionalProperties false -> true")

        for key in TIGHTEN_MIN_KEYS:
            if key in old and key in new and isinstance(old[key], (int, float)) and isinstance(new[key], (int, float)):
                if new[key] > old[key]:
                    reasons.append(f"breaking: {location} tightened {key} {old[key]} -> {new[key]}")
                elif new[key] < old[key]:
                    reasons.append(f"compatible: {location} relaxed {key} {old[key]} -> {new[key]}")

        for key in TIGHTEN_MAX_KEYS:
            if key in old and key in new and isinstance(old[key], (int, float)) and isinstance(new[key], (int, float)):
                if new[key] < old[key]:
                    reasons.append(f"breaking: {location} tightened {key} {old[key]} -> {new[key]}")
                elif new[key] > old[key]:
                    reasons.append(f"compatible: {location} relaxed {key} {old[key]} -> {new[key]}")

        keys = sorted(set(old.keys()) | set(new.keys()))
        for key in keys:
            if key in {"required", "enum", "type", "additionalProperties"} or key in TIGHTEN_MIN_KEYS or key in TIGHTEN_MAX_KEYS:
                continue
            if key in old and key in new:
                child_ptr = f"{location.rstrip('/')}/{key}" if location != "/" else f"/{key}"
                compare_rules(path, old[key], new[key], reasons, child_ptr)
        return

    if old != new:
        reasons.append(f"review-required: {location} changed")

old_files = schema_files(old_root)
new_files = schema_files(new_root)
all_paths = sorted(set(old_files.keys()) | set(new_files.keys()))

entries: list[dict] = []
overall = "unchanged"
for rel in all_paths:
    old_path = old_files.get(rel)
    new_path = new_files.get(rel)
    if old_path is None:
        entry = {"path": rel, "classification": "compatible", "reasons": ["compatible: schema file added"]}
    elif new_path is None:
        entry = {"path": rel, "classification": "breaking", "reasons": ["breaking: schema file removed"]}
    else:
        old_obj = json.loads(old_path.read_text(encoding="utf-8"))
        new_obj = json.loads(new_path.read_text(encoding="utf-8"))
        if old_obj == new_obj:
            entry = {"path": rel, "classification": "unchanged", "reasons": ["unchanged"]}
        else:
            reasons: list[str] = []
            compare_rules(rel, old_obj, new_obj, reasons)
            if any(r.startswith("breaking:") for r in reasons):
                cls = "breaking"
            elif any(r.startswith("review-required:") for r in reasons):
                cls = "review-required"
            elif any(r.startswith("compatible:") for r in reasons):
                cls = "compatible"
            else:
                cls = "review-required"
                reasons.append("review-required: non-trivial schema change")
            entry = {"path": rel, "classification": cls, "reasons": reasons}

    if SEVERITY[entry["classification"]] > SEVERITY[overall]:
        overall = entry["classification"]
    entries.append(entry)

result = {
    "overall_classification": overall,
    "old": str(old_root),
    "new": str(new_root),
    "entries": entries,
}

if out_format == "json":
    print(json.dumps(result, indent=2))
else:
    print(f"schema-diff overall: {overall}")
    print("")
    print("| Path | Classification | Reason |")
    print("|---|---|---|")
    for entry in entries:
        reason = "; ".join(entry["reasons"])[:2000]
        print(f"| {entry['path']} | {entry['classification']} | {reason} |")

if fail_on_breaking and overall == "breaking":
    raise SystemExit(1)
PY
