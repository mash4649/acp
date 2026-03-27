# ACP v1 成立宣言

本宣言は、`public_bundle` における ACP v1 成立条件の達成を記録するものです。

## 宣言

ACP v1 は、以下の成立条件を満たしたため成立と判断します。

1. 公開ガードレールが通過している
2. conformance selftest が通過している
3. bundled non-mock ACP harness adapter による required-external ゲートが通過している
4. Security/Ops minimum（lock, SBOM, vuln-scan, runbook）が実装されている
5. v1 release policy（exit criteria / compatibility / breaking change prohibition）が公開固定されている

## 実行証跡

- 公開ガードレール:
  - `./scripts/public_release_check.sh` -> `ok`
  - 証跡:
    - `conformance/out/v1-evidence.public_release_check.txt`
- conformance selftest:
  - `./scripts/conformance_selftest.sh` -> `ok`
  - 証跡:
    - `conformance/out/v1-evidence.conformance_selftest.txt`
- required-external:
  - 実行: `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
  - 証跡:
    - `conformance/out/v1-evidence.required_external.txt`
    - `conformance/out/release-gate/report.required-external.json`
    - `conformance/out/release-gate/summary.required-external.json`
    - `conformance/out/release-gate/env.required-external.txt`
- security/ops minimum:
  - `./scripts/security_ops_minimum.sh all` -> `ok`
  - `./scripts/security_ops_minimum.sh vuln` -> `no known vulnerabilities (pip-audit)`
  - 証跡:
    - `conformance/out/v1-evidence.security_ops_minimum.txt`

## 再現検証

bundle ルートで `./scripts/verify_v1_bundle.sh` を実行する（初回の `pip` にネットワークが必要）。conformance 依存の導入後、上記ゲートをすべて再実行し、`conformance/out/v1-evidence.*` および `conformance/out/release-gate/`、`conformance/out/security/` を更新します。

## 互換性コミットメント（v1系）

- Core-15 成果物名は v1 系で変更/削除しない
- conformance run contract の required args は後方互換を維持する
- report 必須キーの削除・意味の非互換変更を行わない
- required-external の fail-closed 性を弱めない

## 適用範囲の補足

- この bundle に含まれる広報/説明用文書には、`Status: Draft` 表記が残るものがあります。
- それらは editorial collateral の成熟度を示すものであり、protocol line / conformance 契約 / ここで固定した v1 成立条件を無効化するものではありません。

## post-v1 作業（実装済み）

以下は bundle 内スクリプトとして利用可能です。

1. **parity（reference と外部 runner のレポート差分）**  
   - `./scripts/conformance_parity.sh`（既定: `ACP_PARITY_MODE=reference-external`）  
   - 成果物: `conformance/out/parity/parity-report.<profile>.json`（不一致時は非ゼロ終了）  
   - 既存レポートのみ比較: `ACP_PARITY_MODE=compare-only` と `ACP_PARITY_LEFT_REPORT` / `ACP_PARITY_RIGHT_REPORT`  
   - selftest の `[7/7]` で bundled runner とのゼロ差分を検証

2. **Phase 2/3 negative vectors**  
   - 宣言 `artifact_type` とペイロードの不一致、数値型不整合、`additionalProperties` 違反などの invalid ベクタを追加（manifest / profile と同期）

3. **複数 production runner の比較**  
   - `./scripts/production_runner_compare.sh`  
   - `ACP_HARNESS_RUNNER` と `ACP_HARNESS_RUNNER_2` に別実装を指定し、同一 `ACP_CONFORMANCE_PROFILE` で required-external を2回実行して `target_id` ごとの `verdict` を突き合わせ（内部は `conformance_parity.sh` の `runner-runner` モード）
