Status: Draft
Type: Reference

# ACP メッセージマップ（Core + Surface）

## One-line definition
ACP は委任AI作業の説明責任レイヤです。

## Never-say rules
- ACPを実行フレームワークとして説明しない
- ACPをトランスポートプロトコルとして説明しない
- ACPを決済レールとして説明しない
- 証拠/検証/清算/争議の意味論を混同しない

## Audience map
| Audience | 重要関心 | 見出し | 証拠アンカー | CTA |
|---|---|---|---|---|
| 標準化研究者 | 境界の厳密性・再現性・相互運用性 | 「既存スタックを置き換えない説明責任セマンティクス」 | 3分離原則 + Core-15 | `public_assets/ja/06_comparison_matrix_short.txt`, `public_assets/ja/10_schema_release_plan.md` |
| プロトコル/基盤エンジニア | 決定論的成果物と検証面 | 「監査/再生可能な追記型因果履歴」 | `event`, `evidence_pack`, `verification_report`, `settlement_intent`, `freeze_record` | `./scripts/conformance_selftest.sh` |
| AI実装者/クリエイター | 信頼できる協業と争議対応 | 「委任AIが失敗しても説明責任は消えない」 | delegation edge + reservation + freeze/dispute | `public_assets/ja/05_anchor_use_case.txt` |
| メディア/発信者 | カテゴリの明確さ | 「プロンプトと結果の間を埋める説明責任層」 | narrow core + strong invariants | `public_assets/ja/02_launch_copy_bank.md` |
