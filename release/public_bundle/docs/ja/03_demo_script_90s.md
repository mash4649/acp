# ACP 90秒デモ台本（日本語）

## 目的
ACPをランタイム代替として誤解させず、委任リサーチにおけるアカウンタビリティフローを示します。

## タイムライン
0-15秒: カテゴリ説明
- 「ACP は委任 AI 作業のアカウンタビリティ層です」
- 「実行・通信・決済の代替ではありません」

15-35秒: Agreement から Evidence
- `agreement_v1` / `revision_v1` / `event_v1` を提示
- `event` 系譜に紐づく `evidence_pack_v1` を提示

35-55秒: Verification と Settlement の分離
- `verification_report_v1` の結果を提示
- `settlement_intent_v1` を別成果物として提示
- 「検証は精算ではない」を明示

55-75秒: 委任安全性と紛争フック
- `delegation_edge_v1` + `resource_reservation_v1` を提示
- `freeze_record_v1` の dispute ブランチを提示

75-90秒: 相互運用の締め
- 「ACPは MCP/A2A/ワークフロー/ペイメントを補完します」
- 「狭いコア、強い不変条件、豊富な コンパニオンプロファイル」

## デモで使う成果物
- `examples/minimal-task/*`
- `examples/delegated-research/*`
- `schemas/core/*`

## 登壇ガードレール
- 「agent ランタイム replacement」と言わない
- 証拠 と 検証 を混同しない
- 検証 と 精算 を混同しない
