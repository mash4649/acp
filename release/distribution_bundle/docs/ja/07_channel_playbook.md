# ACP チャネル別プレイブック（日本語）

## 目的
カテゴリ境界を厳密に保ちながら、研究者・クリエイター双方で共有しやすい形にします。

## チャネル別運用
| Channel | 対象 | 主メッセージ | 使用アセット | CTA |
|---|---|---|---|---|
| GitHub Release | エンジニア/メンテナ | 「ランタイム代替ではないアカウンタビリティ層の公開ドラフト」 | `README.md`, `docs/ja/10_schema_release_plan.md` | `./scripts/public_release_check.sh` と `./scripts/conformance_selftest.sh` |
| X / LinkedIn | 研究者/クリエイター | 「委任 AI には再現可能な アカウンタビリティ が必要」 | `docs/ja/02_launch_copy_bank.md` | README と use-case への導線 |
| Blog / Note | 標準化/プロトコル読者 | 「狭いコア + 強い不変条件 + コンパニオンプロファイル」 | `docs/ja/01_message_map.md`, `docs/ja/06_comparison_matrix_short.md` | `docs/ja/14_issue_submission_packet.md` で議論募集 |
| Talk / Demo | インフルエンサー/コミュニティ | 「90秒で成果物と分離原則を示す」 | `docs/ja/03_demo_script_90s.md` | examples/schemas へ誘導 |
| Deep-dive | 実装者 | 「既存スタックに ACP を統合する方法」 | `docs/ja/05_anchor_use_case.md`, `schemas/*`, `conformance/*` | Phase 1 プロファイル から開始 |

## メッセージ分離
- 表層メッセージ: 委任 AI 作業のアカウンタビリティ
- コアメッセージ: 明示的分離原則 + 追記専用 + 再実行可能な不変条件

## 全チャネル共通ガードレール
- 1分以内に「ACP が何ではないか」を明言
- 次のいずれかを必ず含める（短縮形可。定義は `docs/ja/00_package_baseline.md`）
 - `プロンプト != 契約`（指示文は、署名付きの契約境界ではない）
 - `主張 != 証拠`（言っただけでは、再現検証できない）
 - `検証 != 精算`（整合性の確認と、資金・停止などの実行は別）
- 勝者総取り型の置換比較はしません。
