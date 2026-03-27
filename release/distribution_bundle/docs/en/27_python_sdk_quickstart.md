# Python SDK Quickstart

The minimal Python SDK lives in `sdk/python` and provides three small building blocks:

- `validate_artifact(...)` for schema validation
- `build_agreement(...)`, `build_revision(...)`, and `build_event(...)` for artifact creation
- `report_summary(...)` and `report_mismatches(...)` for conformance report parsing

## Install

From the repository root:

```bash
python3 -m pip install -e sdk/python
```

The package also installs a lightweight `acp` CLI.

## Build and validate an artifact

```python
from pathlib import Path

from acp_sdk import build_agreement, build_event, build_revision, validate_artifact

agreement = build_agreement("agr-demo-001", "2026-03-26T00:00:00Z")
revision = build_revision("agr-demo-001", "rev-demo-001", "2026-03-26T00:01:00Z")
event = build_event("agr-demo-001", "rev-demo-001", "evt-demo-001", created_at="2026-03-26T00:02:00Z")

print(validate_artifact(agreement, "agreement", Path(".")))
print(validate_artifact(revision, "revision", Path(".")))
print(validate_artifact(event, "event", Path(".")))
```

The validator looks for `schemas/core/<schema_key>_v1.schema.json` first, then
falls back to `schemas/companion/<schema_key>_v1.schema.json`.

## Parse a report

```python
from acp_sdk import report_mismatches, report_summary

report = {
    "run_id": "demo-001",
    "profile_id": "phase1-accountability-minimum",
    "status": "fail",
    "generated_at": "2026-03-26T00:03:00Z",
    "summary": {"total": 2, "passed": 1, "failed": 1, "notes": []},
    "results": [
        {"target_id": "agreement_valid", "verdict": "match"},
        {"target_id": "revision_missing_id", "verdict": "mismatch", "expected": "pass", "actual": "fail"},
    ],
}

summary = report_summary(report)
mismatches = report_mismatches(report)

print(summary["failed"])
print(mismatches[0]["target_id"])
```

This is intentionally small: it is enough for local validation, smoke tests, and
report inspection without pulling in the full reference harness.

## CLI quick examples

```bash
# Validate an artifact file against a core schema.
acp validate --schema agreement --artifact conformance/cases/phase1/valid_causal_order_agreement_revision_event/artifacts/agreement.json --repo-root .

# Print report summary and mismatches.
acp report summary --report conformance/out/report.phase1.json
acp report mismatches --report conformance/out/report.phase1.json

# Compare two payloads in normalized JSON form.
acp diff --left conformance/vectors/phase3/valid/proof_artifact_valid.json --right conformance/vectors/phase3/invalid/proof_artifact_wrong_artifact_type.json
```
