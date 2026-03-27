# ACP README（公開向け日本語版）

ACP は、**委任された AI 作業**に対して「後から検証できる境界（合意/改訂）と証跡の形式」を提供する **アカウンタビリティ層**です。

ACP は **実行（ランタイム）・通信（トランスポート）・決済（ペイメント）を置き換えません**。それらの上に「説明可能で監査可能な意味論」を追加します。

## まずこれだけ（非エンジニア向け / 1分）

- **何を解決する？**: 「誰が・何を・いつ・どんな根拠で」委任作業を進めたかを、後から追える形で残す
- **何をしない？**: ツール実行の管理、メッセージの配送、お金の移動を ACP 自体は担当しない
- **覚えておく3行**（言い換えつき）:
  - **プロンプトは契約ではありません**（指示文＝約束事ではない）
  - **主張は証拠ではありません**（言っただけでは検証できない）
  - **検証は精算ではありません**（正しい/受け入れ可 と、支払い/凍結/返金 は別）

## エンジニア向け（最短導線）

- **基準（定義・Core-15・非目標）**: `docs/ja/00_package_baseline.md`
- **v1 成立条件と証跡**: `docs/ja/19_v1_declaration.md`
- **再現実行（証跡更新）**: `./scripts/verify_v1_bundle.sh`

## 参照リンク（公開アセット）

- Baseline: `docs/ja/00_package_baseline.md`
- Message map: `docs/ja/01_message_map.md`
- Launch copy bank: `docs/ja/02_launch_copy_bank.md`
- 90s demo: `docs/ja/03_demo_script_90s.md`
- Share FAQ: `docs/ja/04_share_faq.md`
- Anchor use case: `docs/ja/05_anchor_use_case.md`
- Comparison matrix: `docs/ja/06_comparison_matrix_short.md`
- Channel playbook: `docs/ja/07_channel_playbook.md`
- 30s demo: `docs/ja/08_demo_script_30s.md`
- 3min demo: `docs/ja/09_demo_script_3min.md`
- Schema plan: `docs/ja/10_schema_release_plan.md`
- FAQ top5: `docs/ja/11_faq_top5.md`
- Objection memo: `docs/ja/13_objection_memo.md`
- Issue packet: `docs/ja/14_issue_submission_packet.md`
