# ACP v1 リリースポリシー（公開固定）

この文書は、ACP の v1 公開時点で固定する判定基準を定義します。

## 適用範囲

- 対象: `public_bundle` の公開物、`/conformance` 契約、CI ゲート運用
- 非対象: 実行フレームワーク、トランスポート、ペイメント実装の内部仕様

## v1 Exit Criteria

v1 リリースは、以下をすべて満たした時点で成立とします。

1. `./scripts/public_release_check.sh` が成功する
2. `./scripts/conformance_selftest.sh` が成功する
3. `ACP_CONFORMANCE_MODE=required-external` で、harness 契約を満たす non-mock の production adapter 実行が成功する
4. required-external で fail-open が発生しない（runner 未設定/不正時は必ず失敗）
5. 公開ドキュメントに Core-15 固定と非置換立場が維持されている

## 互換性ルール（v1）

- `harness_contract_v1.json` の必須入力（`--contract --profile --request --report`）は後方互換を維持する
- `conformance/templates/report.example.json` の必須フィールド削除は禁止
- 追加フィールドは許可するが、既存コンシューマーを壊さない
- 既存 reason codes/status 語彙の意味を変更しない

## Breaking Change 禁止ルール（v1 系）

v1 系（`1.x`）では、次を breaking change とみなし禁止します。

- Core-15 成果物名の変更/削除
- conformance run contract の必須引数変更
- report の必須キー削除、または既存キー意味の非互換変更
- required-external の fail-closed 性を弱める変更

## 補足

- 広報/説明用文書に `Status: Draft` 表記が残ることがあります。
- それは copy maturity を示すものであり、protocol line / conformance 契約 / この bundle の v1 成立条件を否定するものではありません。

## 変更管理

- 非互換が必要な変更は v2 で扱う
- v1 系の変更は「非破壊追加」「説明改善」「運用強化」に限定する
- 変更時は `docs/ja/16_v1_release_execution_plan.md` の進捗表と同期する
