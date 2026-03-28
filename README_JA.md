# ACP (AI Contract Protocol)

ACP は、委任された AI 作業の説明責任レイヤーです。

ACP は実行フレームワークでも、トランスポートプロトコルでも、決済レールでもありません。

## タグライン

委任された AI 作業を、契約・検証・清算まで具体的に追跡できる説明責任プロトコル。

## 覚えておく3行

- Prompt は契約ではない。
- Claim は証拠ではない。
- Verification は清算ではない。

## ディレクトリ役割

- `docs/` = 正本となる説明書
- `assets/` = 編集可能な公開素材
- `release/` = 固定された配布物

---

## Demo

30秒デモはこの流れが最短です。

1. `examples/minimal-task/` の成果物を表示する
2. `./scripts/conformance.sh run --reference` を実行する
3. `conformance/out/` の検証レポートを見せる
4. ACP が **実行** と **説明責任** を分離している点を強調する

表示イメージ:

`タスク成果物 -> ACP conformance 実行 -> 検証レポート -> 清算意思`

---

## TL;DR

ACP は **検証できない委任 AI 作業** を解決します。

Without:

- プロンプトとログが混ざる
- 「完了した」という主張が証拠と結びつかない
- 検証と清算の判断が曖昧になる

With:

- 合意・改訂・イベント・証拠・報告を明示的な成果物として分離する
- 検証を再実行可能かつ機械可読に統一する
- 清算意思を独立した成果物として出す

Think of it as:

**委任 AI の説明責任に対する Git 的なトレーサビリティ。**

---

## Why this exists

- 既存の AI ツールは実行速度を重視し、監査可能な説明責任が弱い
- マルチエージェントや外部委託のワークフローでは、チャット履歴だけでは十分ではない
- 多くのチームは「誰が・何に・いつ合意し・何で検証したか」をツール横断で証明できない

---

## What it does

```text
Runtime / Agent Tool A ─┐
Runtime / Agent Tool B ─┼──▶ ACP Artifacts + Rules ───▶ Verifiable Report
Runtime / Agent Tool C ─┘
```

ACP が標準化するもの:

- 契約成果物 (`agreement_v1`, `revision_v1`, `event_v1`)
- 証拠・証明成果物 (`evidence_pack_v1`, `proof_*`)
- 検証・清算成果物 (`verification_report_v1`, `settlement_intent_v1`)

---

## Quick Start

### Install

```bash
git clone https://github.com/mash4649/acp.git
cd acp
./scripts/install_conformance_deps.sh
```

### Run

```bash
./scripts/conformance.sh run --reference
```

### Example

```bash
./scripts/conformance.sh run --mock
ls conformance/out
```

---

## Features

- Core-15 スキーマを前提にした契約ファーストの成果物モデル
- phase プロファイル、vectors、cases による再実行可能な適合性検証
- `ACP_HARNESS_RUNNER` を使った外部ハーネス連携
- EN/JA ドキュメントと公開バンドルの同梱

---

## Architecture

- `schemas/`: プロトコル定義（core / companion / meta / vectors）
- `conformance/`: プロファイル、テストベクトル、不変条件ケース、レポートスキーマ
- `scripts/`: 検証、conformance 実行、bundle 生成の補助
- `examples/`: minimal / delegated-research の参照バンドル
- `sdk/`: JS と Python の SDK パッケージ
- `assets/`: ローンチ文言、FAQ、デモ台本、スキーマテンプレート

---

## Use Cases

- 委任開発での証跡付き受け入れ判定
- マルチエージェント運用での因果とポリシー検証
- 外部ベンダー連携時の証拠ベース合意

---

## Comparison

| Feature | Existing Tools | ACP |
| ------- | -------------- | --- |
| Prompt 履歴 | あり | それだけでは不十分 |
| 機械可読な契約成果物 | まれ | あり（Core-15） |
| 検証レポートの標準スキーマ | 個別実装が多い | あり |
| 清算意思の独立成果物化 | 暗黙が多い | あり |
| fail-closed 外部ゲート | 場当たり実装が多い | あり |

---

## Ecosystem Position

| Category | Tools | Relation |
| -------- | ----- | -------- |
| エージェント通信 | MCP / A2A | ACP は補完関係 |
| 実行オーケストレーション | Airflow / Temporal / 独自ランタイム | ACP は説明責任成果物を追加する |
| 決済レール | Stripe / stablecoin 系 | ACP は清算意思セマンティクスを提供する |
| 証拠検証 | 独自スクリプト群 | ACP は構造を標準化する |

---

## Roadmap

- 本番向けの外部ハーネス例を拡充する
- 認定スイートの配布とレジストリ運用を強化する
- SDK の使い勝手とエンドツーエンドのテンプレートを改善する

---

## Documentation

| Topic | Link |
| ----- | ---- |
| 英語ドキュメント索引 | `docs/en/README.md` |
| 日本語ドキュメント索引 | `docs/ja/README.md` |
| 統合索引 | `docs/README.md` |
| 初見向けリポジトリ全体図 | `docs/ja/リポジトリ全体図.md` |
| 公開素材索引 | `assets/README.md` |
| 配布範囲ガイド | `DISTRIBUTION_SCOPE.md` |
| コントリビューション | `CONTRIBUTING.md` |
| ガバナンス | `GOVERNANCE.md` |

---

## Contributing

大きな変更は先に Issue で相談し、検証結果付きで PR を出してください。
詳細は `CONTRIBUTING.md` を参照してください。

---

## License

Apache-2.0 (`LICENSE`)
