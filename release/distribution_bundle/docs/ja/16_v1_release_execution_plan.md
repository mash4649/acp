# ACP v1 リリース実行計画（Blocker 分離版）

この計画は、v1 を成立させるための必須条件（Release blockers）と、v1 後に効く強化項目を分離して定義します。  
前提として、`public_release_check.sh` で確定しているのは「公開物ガードレール通過」です。  
したがって最優先は、external harness 中心の相互運用リリース成立条件です。

## スコープ分類

### Release blockers（v1 成立に必須）
1. external runner 契約の固定
2. 失敗分類と終了コードの標準化
3. reference/external 判定 parity
4. required-external の常時 fail-closed 化
5. Phase 2/3 の代表 negative cases 完了
6. v1 exit criteria と互換性ルールの固定
7. external harness 障害時ランブック

### Near-term hardening（v1 直後の強化）
- negative vectors の拡張
- 証拠完全性検証の強化
- 依存固定、SBOM、脆弱性スキャン
- freeze/dispute 運用手順
- ワンコマンド検証と self-heal

### Post-v1 growth（普及・成長）
- 実案件テンプレート追加
- 他レイヤ参照実装
- KPI と採用事例収集

## 実行順（推奨）

### 1) Runner contract v1.1 固定
- **担当レイヤ**: Conformance contract / CLI
- **目的**: 実装前に判定面を固定し、CI と report 互換の揺れを防ぐ
- **DoD**
  - `ACP_HARNESS_RUNNER` の入力（`--contract --profile --request --report`）が文書化されている
  - report shape（必須フィールド・バージョン・互換条件）が固定されている
  - 終了コード（成功/検証失敗/環境障害）と stderr 方針が固定されている
  - `reference_harness.py` と `mock_external_runner.sh` が同契約で通る

### 2) External harness 実装
- **担当レイヤ**: External runtime adapter
- **目的**: 実運用を想定した external モード成立
- **DoD**
  - `ACP_CONFORMANCE_MODE=required-external` で mock runner を拒否できる
  - 実 runner で成功系・検証失敗系・環境障害系を分離して返せる
  - CI で external gate が fail-closed で動作する

### 3) Parity suite 追加
- **担当レイヤ**: Conformance parity tests
- **目的**: 量より先に判定一致を担保
- **DoD**
  - 同一 fixture に対して reference/external の `status` が一致する
  - 同一 fixture に対して `results[].verdict` が一致する
  - 差分発生時に再現できる最小 fixture が保存される

### 4) Phase 2/3 強化（代表ケース優先）
- **担当レイヤ**: Profiles / vectors / invariants
- **目的**: v1 成立に必要な否定系の穴を埋める
- **DoD**
  - 代表正系 + 各 invariant の代表否定系がそろう
  - reference gate（Phase 2/3）が required で安定稼働する
  - CI 上で再実行時のフレークが許容範囲内に収まる

### 5) v1 stabilization docs
- **担当レイヤ**: Spec governance / release policy
- **目的**: v1 判定基準の曖昧さを解消
- **DoD**
  - breaking change 禁止ルールが公開文書に明記される
  - version compatibility ルールが公開文書に明記される
  - v1 exit criteria が公開文書に反映される

### 6) Security/ops minimum
- **担当レイヤ**: Security baseline / operations
- **目的**: v1 に必要な最低運用と信頼性を満たす
- **DoD**
  - 依存固定（lock 方針）が定義される
  - SBOM 生成と脆弱性スキャンの最小パイプラインが用意される
  - fail-closed 時の運用手順がランブック化される
  - freeze/dispute の最小手順が定義される

## 優先度の原則（意思決定ルール）
- **原則 1**: 実装前に契約を固定する
- **原則 2**: テスト量より parity を優先する
- **原則 3**: v1 blocker と post-v1 を混在させない
- **原則 4**: fail-open を許容しない（required-external は常に fail-closed）

## 進捗管理テンプレート（運用用）

| 項目 | 担当レイヤ | 状態 | DoD 達成率 | ブロッカー |
|---|---|---|---|---|
| Runner contract v1.1 固定 | Conformance contract / CLI | In progress | 85% | 契約バージョン名（v1/v1.1）の公開表記統一 |
| External harness 実装 | External runtime adapter | Done | 100% | - |
| Parity suite 追加 | Conformance parity tests | In progress | 65% | reference/external 同一 fixture の差分比較レポート自動化 |
| Phase 2/3 強化 | Profiles / vectors / invariants | In progress | 80% | 代表否定系の追加拡張（網羅率向上） |
| v1 stabilization docs | Spec governance / release policy | Done | 100% | - |
| Security/ops minimum | Security baseline / operations | Done | 100% | - |

## 最新検証ログ（v1 事前確認）

- 実行日: 2026-03-24
- 実行コマンド:
  - `./scripts/public_release_check.sh`
  - `./scripts/conformance_selftest.sh`
  - `./scripts/security_ops_minimum.sh all`
  - `./scripts/security_ops_minimum.sh vuln`
  - `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
- 結果:
  - 公開ガードレール: `public-release-check: ok`
  - conformance selftest:
    - mock/reference/phase2/phase3: すべて `ok`
    - external(contract smoke): `ok`
    - required-external negative-path（mock 拒否）: 期待どおり失敗を観測
  - security/ops minimum:
    - lock fingerprint: 生成済み（`conformance/out/security/requirements-conformance.sha256`）
    - sbom-min: 生成済み（`conformance/out/security/sbom-min.json`）
    - vuln-scan: `pip-audit --no-deps --disable-pip` で実行済み、既知脆弱性なし（`conformance/out/security/vuln-scan.txt`）
  - required-external release gate:
    - 実行 runner: `./scripts/acp_harness_runner.sh`
    - status: `pass` / `summary.failed: 0`
    - 証跡: `conformance/out/release-gate/report.required-external.json`, `conformance/out/release-gate/summary.required-external.json`

## v1 リリース直前の最終ゲート

1. `ACP_HARNESS_RUNNER` に external runner を設定して `required-external` を通す ✅
   - 実行: `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
   - 成果物: `conformance/out/release-gate/report.required-external.json`, `summary.required-external.json`
2. `v1 exit criteria` / 互換性ルール / breaking change 禁止を公開文書に固定する（`docs/ja/17_v1_release_policy.md`, `docs/en/17_v1_release_policy.md`） ✅
3. Security/ops minimum（lock 方針、SBOM、脆弱性スキャン、ランブック）を最小構成で実装する（runbook: `docs/ja/18_security_ops_minimum_runbook.md` / `docs/en/18_security_ops_minimum_runbook.md`） ✅

## v1 成立宣言（公開）

- 日本語: `docs/ja/19_v1_declaration.md`
- 英語: `docs/en/19_v1_declaration.md`
