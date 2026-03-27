# Python SDK クイックスタート

最小の Python SDK は `sdk/python` にあり、次の3つを提供します。

- `validate_artifact(...)` によるスキーマ検証
- `build_agreement(...)` / `build_revision(...)` / `build_event(...)` によるアーティファクト生成
- `report_summary(...)` / `report_mismatches(...)` による conformance レポート解析

## インストール

リポジトリルートから実行します。

```bash
python3 -m pip install -e sdk/python
```

このパッケージは軽量 CLI `acp` も同時にインストールします。

## アーティファクトを作成して検証する

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

検証時はまず `schemas/core/<schema_key>_v1.schema.json` を探し、見つから
ない場合は `schemas/companion/<schema_key>_v1.schema.json` を参照します。

## レポートを解析する

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

この SDK は軽量なローカル検証と smoke test、レポート確認に絞って
います。フルの reference harness は別にあります。

## CLI クイック例

```bash
# コアスキーマに対してアーティファクトを検証
acp validate --schema agreement --artifact conformance/cases/phase1/valid_causal_order_agreement_revision_event/artifacts/agreement.json --repo-root .

# レポート要約と mismatch 一覧を出力
acp report summary --report conformance/out/report.phase1.json
acp report mismatches --report conformance/out/report.phase1.json

# 2つの JSON を正規化して差分表示
acp diff --left conformance/vectors/phase3/valid/proof_artifact_valid.json --right conformance/vectors/phase3/invalid/proof_artifact_wrong_artifact_type.json
```
