Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# Public Package Index (JA)

このディレクトリは、公開向け資料を日本語で整理したものです。

## Files
- 00_package_baseline.txt: パッケージ全体の編集方針
- 01_message_map.md: 対象読者ごとのメッセージマップ
- 02_launch_copy_bank.md: ローンチ文面テンプレート
- 03_demo_script_90s.md: 90秒デモ台本
- 04_share_faq.md: 外部共有向けFAQ
- 05_anchor_use_case.txt: 委任リサーチの代表ユースケース
- 06_comparison_matrix_short.txt: 責務分離の比較表（短縮版）
- 07_channel_playbook.md: 配信チャネル別ガイド
- 08_demo_script_30s.md: 30秒版デモ台本
- 09_demo_script_3min.md: 3分版デモ台本
- 10_schema_release_plan.md: Core-15維持の段階的公開計画
- 11_faq_top5.md: README埋め込み向けFAQ（5問）
- 12_readme_repo_ready.md: 公開リポジトリ向けREADME原稿
- 13_objection_memo.md: 標準化レビュー向け反論対応メモ
- 14_issue_submission_packet.md: Issue投稿テンプレート
- schema_templates/phase1/: Phase 1公開用テンプレート

## Editorial intent
- 公開資料は簡潔に、境界を崩さない。
- 内部評価・代替案・失敗例はこのフォルダ外で管理する。
- すべて Core-15 と「非代替（補完）」の立場に合わせる。

## Release helper
- 公開前に `./scripts/public_release_check.sh` を実行する。
- この bundle は生成済み。再生成はソースリポジトリで `./scripts/prepare_public_bundle.sh` を使う。
