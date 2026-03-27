# Issue 投稿パケット（日本語）

## タイトル（貼り付け用）
Discussion: Delegated AI Work 向け Minimal Accountability Layer（Non-Replacement Scope）

## 本文（貼り付け用）
本提案は、委任 AI ワークフローにおける狭い相互運用境界としての アカウンタビリティ層 を議論するものです。既存の トランスポート / 実行 / ペイメント を補完し、置き換える提案ではありません。

対象スコープは、不変リビジョン 下の 認可、証拠 提出、検証結果、精算意図 結果、紛争/凍結 commitment の意味論に限定します。

この議論が必要な理由:
- 委任 AI ワークフローは多段・多主体化している
- 実行トレースだけではスタック横断 アカウンタビリティ が不足する
- 実装非依存で再現可能な境界意味論が必要

レイヤ分離:
- communication protocols: message exchange
- 実行 frameworks: planning/tool orchestration
- ペイメントレール?: value movement/finality
- アカウンタビリティ層: 契約/証拠/検証/精算/紛争意味論

必須分離（短縮）:
- `プロンプト != 契約` / `主張 != 証拠` / `検証 != 精算`（詳細定義は `docs/ja/00_package_baseline.md`）

議論単位（提案）:
1. signed causal 追記専用 event history
2. 検証/精算 semantic separation
3. 明示入力による 再実行可能なポリシー評価
4. safe child activation（delegation DAG safety + reservation coverage）
5. 紛争/凍結 意味論

本パケットで固定済み前提:
- proof abstraction は core scope
- delegation DAG safety と reservation safety は core scope
- effective ポリシー projection と 明示的な time facts は コアのアカウンタビリティ表現面
- 紛争/凍結 は コアフック

議論の依頼:
既存プロトコル置換や固定済み境界の再オープンではなく、最小相互運用表現（フィールド群・語彙）へのコメントをお願いします。

## レビューチェックリスト
- 非置換 framing が明示されている
- コア/コンパニオン 境界が維持されている
- 証拠/検証/精算/dispute が混同されていない
- open questions が表現レベルに限定されている
- トランスポート/実行/ペイメント の scope creep がない

## 参照ドラフト
- `docs/ja/00_package_baseline.md`
- `docs/ja/10_schema_release_plan.md`
- `docs/ja/06_comparison_matrix_short.md`
- `docs/ja/11_faq_top5.md`
