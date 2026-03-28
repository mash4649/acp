# ACP (AI Contract Protocol)

## Tagline

委任された AI 作業を、契約・検証・清算まで具体的に追跡できる説明責任プロトコル。

---

## Demo

30秒デモはこの流れが最短です:

1. `examples/minimal-task/` の成果物を表示
2. `./scripts/conformance.sh run --reference` を実行
3. `conformance/out/` の検証レポートを確認
4. 「実行」と「説明責任」を分離できる点を強調

表示イメージ:

`タスク成果物 -> ACP検証実行 -> 検証レポート -> 清算意思`

## ディレクトリ役割

- `docs/` = 正本となる説明書
- `assets/` = 編集可能な公開素材
- `release/` = 固定された配布物

---

## TL;DR

ACP は **委任AI作業が検証できない問題** を解決します。

Without:

- プロンプトやログが混ざり、監査しにくい
- 「完了した」という主張と証拠が結びつかない
- 検証結果と清算判断が曖昧になる

With:

- 合意・改訂・イベント・証拠・報告を成果物として分離
- 検証を再実行可能かつ機械可読に統一
- 清算意思を独立成果物として明示

Think of it as:

**委任AIの説明責任のための Git 的トレーサビリティ。**

---

## Why this exists

- 既存ツールは実行効率を重視し、説明責任モデルが弱い
- マルチエージェントや外注連携では、チャット履歴だけでは合意証跡にならない
- 「誰が・何を・いつ合意し・何で検証したか」を横断的に証明しづらい

---

## What it does

```text
Runtime / Agent Tool A ─┐
Runtime / Agent Tool B ─┼──▶ ACP成果物 + ルール ───▶ 検証可能レポート
Runtime / Agent Tool C ─┘
```

ACP が標準化する成果物:

- 契約系 (`agreement_v1`, `revision_v1`, `event_v1`)
- 証拠/証明系 (`evidence_pack_v1`, `proof_*`)
- 検証/清算系 (`verification_report_v1`, `settlement_intent_v1`)

---

## Quick Start

### Install

```bash
git clone https://github.com/mash4649/acp-project.git
cd acp-project
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

- Contract-first な成果物モデル（Core-15）
- 再現可能な適合性検証（profiles + vectors + cases）
- `ACP_HARNESS_RUNNER` による外部ランナー連携
- EN/JA ドキュメントと公開バンドル同梱

---

## Architecture

- `schemas/`: プロトコル定義（core/companion/meta/vectors）
- `conformance/`: プロファイル、テストベクトル、不変条件ケース、レポートスキーマ
- `scripts/`: 検証、実行、バンドル生成の操作群
- `examples/`: minimal / delegated-research の参照バンドル
- `sdk/`: JS / Python SDK
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
| プロンプト履歴管理 | あり | それだけでは不十分 |
| 機械可読な契約成果物 | まれ | あり（Core-15） |
| 検証レポートの標準スキーマ | 個別実装が多い | あり |
| 清算意思の独立成果物化 | 暗黙が多い | あり |
| fail-closed 外部ゲート | 場当たり実装が多い | あり |

---

## Ecosystem Position

| Category | Tools | Relation |
| -------- | ----- | -------- |
| エージェント通信 | MCP / A2A | ACP は補完関係 |
| 実行オーケストレーション | Airflow / Temporal / 独自ランタイム | ACP は説明責任成果物を追加 |
| 決済レール | Stripe / stablecoin 系 | ACP は清算意思セマンティクスを提供 |
| 証拠検証 | 独自スクリプト群 | ACP は構造を標準化 |

---

## Roadmap

- 本番向け外部ランナー連携例の拡充
- 認定スイート配布とレジストリ運用の強化
- SDK 開発体験とテンプレート整備の改善

---

## Documentation

| Topic | Link |
| ----- | ---- |
| 英語ドキュメント索引 | `docs/en/README.md` |
| 日本語ドキュメント索引 | `docs/ja/README.md` |
| 統合索引 | `docs/README.md` |
| 公開素材索引 | `assets/README.md` |
| 公開範囲ガイド | `DISTRIBUTION_SCOPE.md` |
| コントリビューション | `CONTRIBUTING.md` |
| ガバナンス | `GOVERNANCE.md` |

---

## Contributing

大きな変更は先に Issue で相談し、検証結果付きで PR を作成してください。
詳細は `CONTRIBUTING.md` を参照してください。

---

## License

Apache-2.0 (`LICENSE`)
