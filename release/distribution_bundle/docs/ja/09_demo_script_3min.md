# ACP 3分デモ台本（日本語）

## 目的
researcher/implementer に十分な技術深度を示しつつ、非置換の立場を維持します。

## セグメント1（0:00-0:40）
- 「ACP は委任 AI 作業のアカウンタビリティ層」
- 「実行・通信・決済そのものではない」
- 3つの分離原則を提示（短い言い換えつき。定義は `docs/ja/00_package_baseline.md`）
 - **プロンプトは契約ではありません**（指示文は「署名され、改訂に固定された境界」ではない）
 - **主張は証拠ではありません**（言っただけでは、第三者が再現検証できない）
 - **検証は精算ではありません**（正しさ/受理 と、支払い/凍結/返金 は別の意思決定）

## セグメント2（0:40-1:30）
- `agreement_v1` と `revision_v1` から開始
- 追記専用 な `event_v1` 連鎖を提示
- `evidence_pack_v1` を接続
- `verification_report_v1` を独立成果物として提示
- `settlement_intent_v1` を別意思決定層として提示

## セグメント3（1:30-2:20）
- `delegation_edge_v1` で child work を開始
- 起動前に `resource_reservation_v1` を強制
- `data_policy_binding_v1` / `effective_policy_projection_v1` / `time_fact_v1` を replay 入力として説明

## セグメント4（2:20-3:00）
- 紛争経路を起動し `freeze_record_v1` を出力
- 既存成果物は不変、解決は追記で表現することを説明
- 締め: 「ACPは MCP/A2A/ワークフロー/ペイメントを アカウンタビリティ意味論で補完する」

## デモ参照
- `examples/minimal-task/*`
- `examples/delegated-research/*`
- `schemas/core/*`
- `conformance/profiles/phase1.profile.json`

## 話者ガードレール
- ACP を万能 agent protocol として売り込まない
- 検証と精算実行を混同しない
- ACP に トランスポート が含まれると示唆しない
