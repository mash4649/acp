# ACP メッセージマップ（日本語）

## 一文定義
ACPは、委任された AI 作業のためのアカウンタビリティ層です。

## 禁止表現
- ACP を実行フレームワークとして説明しません。
- ACP をトランスポートプロトコルとして説明しません。
- ACP を決済レールとして説明しません。
- 証拠 / 検証 / 精算 / 紛争を混同しません。

## オーディエンス別マップ
| Audience | 関心 | 表層メッセージ | コア根拠 | CTA |
|---|---|---|---|---|
| Standards researchers | 境界の精密さ、再現性、相互運用 | 「既存スタックを置き換えないアカウンタビリティ意味論」 | `プロンプト != 契約` / `主張 != 証拠` / `検証 != 精算` + Core-15 | `docs/ja/06_comparison_matrix_short.md` と `docs/ja/10_schema_release_plan.md` を確認 |
| Protocol/infra engineers | 決定論的な成果物と検証面 | 「監査・再生可能な追記専用因果履歴」 | `event` `evidence_pack` `verification_report` `settlement_intent` `freeze_record` | `./scripts/conformance_selftest.sh` を実行 |
| AI builders/creators | 信頼できる協業と紛争対応 | 「委任作業が失敗してもアカウンタビリティが消えない」 | delegation edge + reservation + freeze/dispute | `docs/ja/05_anchor_use_case.md` を確認 |
| Influencers/media | カテゴリの明確さと必要性 | 「ACPは プロンプト と アウトカムの間に不足していたアカウンタビリティ層」 | 狭いコア + 強い不変条件 + コンパニオンプロファイル | `docs/ja/02_launch_copy_bank.md` を活用 |

## 30秒ナラティブ
委任 AI 作業は、多様なランタイム・ツール・組織を横断します。ログだけでは共有可能なアカウンタビリティは成立しません。ACPは、agreement/revision、追記専用因果イベント、証拠連動検証、明示的な精算意図、紛争/凍結 を定義する狭い相互運用境界です。ACPは トランスポート / 実行 / ペイメント を置き換えず補完します。
