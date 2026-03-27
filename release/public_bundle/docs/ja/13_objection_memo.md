# ACP 異議対応メモ（日本語）

## O1. 「また別の agent protocol では？」
回答:
いいえ。ACP は委任 AI の アカウンタビリティ意味論に限定され、トランスポートと実行 は明示的に対象外です。

根拠:
- `docs/ja/06_comparison_matrix_short.md`
- `README.md` の「What ACP Is Not」

## O2. 「ワークフローログ で十分では？」
回答:
ログは実行ローカルでスタック依存になりがちです。ACPは 契約/証拠/検証/精算意図/紛争/凍結 を横断的に表現する相互運用成果物を定義します。

根拠:
- `docs/ja/05_anchor_use_case.md`
- `schemas/core/*`

## O3. 「なぜ 検証 と 精算 を分ける？」
回答:
分離により意図しない リリース意味論を防ぎ、紛争ガバナンス を維持できます。検証結果は精算ファイナリティと同義ではありません。

根拠:
- `docs/ja/11_faq_top5.md`
- `schemas/core/verification_report_v1.schema.json`
- `schemas/core/settlement_intent_v1.schema.json`

## O4. 「ACPは MCP/A2A の代替になる？」
回答:
なりません。ACPは 通信/実行 レイヤを補完します。

根拠:
- `docs/ja/01_message_map.md`
- `docs/ja/06_comparison_matrix_short.md`

## O5. 「Core の 15 は多すぎるのでは？」
回答:
Core-15 は不変境界です。公開は段階化できますが、コア意味論をより小さい集合へ再定義すべきではありません。

根拠:
- `docs/ja/10_schema_release_plan.md`
- `README.md` の「Core Artifacts」
