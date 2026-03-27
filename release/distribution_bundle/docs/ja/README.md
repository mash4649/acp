# Public パッケージ索引（日本語）

このフォルダには、日本語の公開向け文書を格納しています。

## 言語ナビゲーション
- 日本語索引（このファイル）: `docs/ja/README.md`
- 英語索引: `docs/en/README.md`
- 日英統合索引: `docs/README.md`

## 含まれるファイル
- `00_package_baseline.md`: パッケージ全体の編集基準
- `01_message_map.md`: 対象読者別メッセージマップ
- `02_launch_copy_bank.md`: ローンチ用コピー集
- `03_demo_script_90s.md`: 90 秒デモ台本
- `04_share_faq.md`: 外部共有向け FAQ
- `05_anchor_use_case.md`: 委任型リサーチのアンカー事例
- `06_comparison_matrix_short.md`: 責務クラス比較表（短縮版）
- `07_channel_playbook.md`: チャネル別発信ガイド
- `08_demo_script_30s.md`: 30 秒デモ台本
- `09_demo_script_3min.md`: 3 分デモ台本
- `10_schema_release_plan.md`: Core-15 を維持した段階公開計画
- `11_faq_top5.md`: README 埋め込み向け FAQ
- `12_readme_repo_ready.md`: リポジトリ公開向け README 文案
- `13_objection_memo.md`: 典型的な異議への対応メモ
- `14_issue_submission_packet.md`: Issue 投稿テンプレート
- `15_real_world_impact.md`: 実務的なインパクトと導入時の位置づけ
- `16_v1_release_execution_plan.md`: v1 成立条件を blocker と強化項目に分離した実行計画（DoD / 担当レイヤ付き）
- `17_v1_release_policy.md`: v1 exit criteria / 互換性 / breaking change 禁止を固定する公開ポリシー
- `18_security_ops_minimum_runbook.md`: lock/SBOM/脆弱性スキャン/fail-closed 対応の最小 runbook
- `19_v1_declaration.md`: v1 成立条件の達成宣言と証跡一覧
- `20_post_v1_roadmap.md`: 成熟・普及に向けた post-v1 ロードマップ
- `22_harness_implementation_guide.md`: 本番ランナー契約と統合ガイド
- `23_schema_versioning_policy.md`: 機械可読な互換性と版管理ポリシー
- `24_conformance_certification.md`: 認定レベル、必要証跡、バッジ運用
- `25_integration_patterns.md`: 周辺システムとの実務的な統合パターン
- `26_certification_test_suite.md`: 配布可能な認定テストスイート生成と証跡要件
- `27_python_sdk_quickstart.md`: 最小 Python SDK と `acp` CLI のクイックスタート
- `28_conformant_implementation_registry.md`: 適合実装レジストリの運用と公開手順
- `29_transport_agnostic_artifact_exchange_protocol.md`: ACP 成果物を交換するトランスポート非依存パッケージ仕様

## 編集方針
- 公開文書は簡潔で境界がぶれないこと。
- Core-15 と非置換の立場を維持すること。

## リリース補助
- 公開前に `./scripts/public_release_check.sh` を実行してください。
- v1 監査証跡を更新する場合は `./scripts/verify_v1_bundle.sh` を実行してください（`conformance/out/` を更新。詳細は `19_v1_declaration.md`）。
- このリポジトリ自体が public bundle のルートです。`./scripts/prepare_public_bundle.sh` は同梱されません。フル ACP 開発ツリーを別途持つ場合のみ、そちらのパッケージングスクリプトで `release/distribution_bundle/` を配布用パスへコピーしてください。
