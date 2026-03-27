# ACP v1 Security/Ops Minimum Runbook

この runbook は、v1 リリース直前に必要な最小運用（lock/SBOM/脆弱性スキャン/fail-closed 対応）を定義します。

## 1. 事前確認

1. `./scripts/public_release_check.sh`
2. `./scripts/conformance_selftest.sh`
3. `./scripts/security_ops_minimum.sh doctor`

上記がすべて成功してから次へ進みます。

## 2. Lock 方針（最小）

- 対象ファイル: `requirements-conformance.lock`（lock 不在時は `requirements-conformance.txt` をフォールバック）
- 実行: `./scripts/security_ops_minimum.sh lock`
- 生成物: `conformance/out/security/requirements-conformance.sha256`

運用ルール:

- `requirements-conformance.lock`（またはフォールバック `requirements-conformance.txt`）を変更した場合は hash を再生成する
- リリースレビューでは hash 生成日時と差分を確認する

## 3. SBOM 生成（最小）

- 実行: `./scripts/security_ops_minimum.sh sbom`
- 生成物: `conformance/out/security/sbom-min.json`

運用ルール:

- v1 では最小 SBOM（requirements ベース）を採用する
- 将来拡張時は CycloneDX/SPDX へ移行してもよいが、v1 判定には必須ではない

## 4. 脆弱性スキャン（最小）

- 実行: `./scripts/security_ops_minimum.sh vuln`
- 生成物: `conformance/out/security/vuln-scan.txt`
- 実行方式:
  - 優先: `pip-audit`（`--no-deps --disable-pip`）
  - 代替: `uvx --from pip-audit pip-audit --no-deps --disable-pip`

判定:

- `pip-audit` または `uvx` 利用可能: 検出結果を評価し、High/Critical はリリース前に対処
- どちらも未導入: `vuln-scan.txt` に skip 理由を記録し、導入 TODO を残す

## 5. fail-closed 障害時の一次対応

症状例:

- `ACP_CONFORMANCE_MODE=required-external` が失敗
- `ACP_HARNESS_RUNNER` 未設定/非実行可能/契約不一致

対応手順:

1. `ACP_HARNESS_RUNNER` のパスと実行権限を確認
2. `./scripts/conformance_ci.sh` を `required-external` で再実行
3. 失敗ログ（stderr）を保存し、契約引数（`--contract --profile --request --report`）一致を確認
4. 復旧不能な場合はリリースを停止（fail-open 禁止）

## 6. freeze/dispute 最小運用

- 紛争開始時は `dispute.opened` イベントを記録
- 状態固定が必要な場合は `freeze_record_v1` を発行
- `verification` と `settlement` の判断を混同しない

## 7. v1 リリース判定チェックリスト

- [ ] `public_release_check.sh` 成功
- [ ] `conformance_selftest.sh` 成功
- [ ] `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/external_release_gate.sh` 成功
- [ ] lock fingerprint 更新済み
- [ ] sbom-min.json 更新済み
- [ ] vuln-scan.txt 確認済み
- [ ] fail-closed/freeze/dispute 手順を運用担当が確認済み
