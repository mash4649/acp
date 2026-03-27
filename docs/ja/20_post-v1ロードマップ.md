# ACP post-v1 ロードマップ — 成熟と普及に向けて

> **目的**: v1 成立後、ACP が次段階（v1.x 強化→v2 設計→広範な採用）へ進むために必要な課題・検討事項・仕様を体系的に整理する。  
> **対象読者**: プロジェクトオーナー、コントリビューター、導入検討者。  
> **前提**: v1 成立条件は `docs/ja/19_v1_declaration.md` で達成済み。v1 互換性ルールは `docs/ja/17_v1_release_policy.md` で固定済み。

> **ステータス更新（2026-03-27）**: K-1/K-2/K-3/K-4/K-5、C-1/C-2/C-3/C-4/C-5、A-1/A-2/A-3/A-4、B-1/B-2/B-3/B-4、D-1/D-2/D-3/D-4/D-5、E-1/E-2/E-3/E-4、F-1/F-2/F-3、G-1/G-2/G-3、H-1/H-2/H-3、I-1/I-3 は実装済み。

---

## 現状サマリ（v1 到達点）

| 領域 | 達成済み | 未着手・不足 |
|------|---------|-------------|
| **スキーマ** | Core-15 全スキーマ＋companion 9 種＋meta 2 種 | companion ベクトルは 9/9 でカバー済み。スキーマ間 `$ref` なし（各自独立）。進化ルールは人間向けのみ |
| **Conformance** | Phase1/2/3 プロファイル、38 ベクトル、10 不変条件ケース、parity | Phase1 にケース無し。外部ハーネス認定プログラムは未整備。 |
| **CI/CD** | `conformance.yml`（親リポジトリ）、selftest 7 ステップ | bundle 単体用 CI 無し。Dependabot/CodeQL 未設定 |
| **ドキュメント** | 日英 19 文書＋README 群。baseline / 分離原則 / v1 宣言 | `15_real_world_impact` 日本語版無し。`16_v1_release_execution_plan` 英語版無し。SDK/統合ガイド無し |
| **例** | `minimal-task`（6 ファイル）、`delegated-research`（8 ファイル） | Phase3 proof/companion のエンドツーエンド例無し。自動バリデーション手順無し |
| **セキュリティ** | ピン留め requirements、SHA256 fingerprint、最小 SBOM、pip-audit | ロックファイル無し。Dependabot/自動スキャン未設定 |
| **プロジェクト運営** | リリースポリシー固定、breaking change 禁止 | GOVERNANCE / CONTRIBUTING / CoC 未整備。パッケージマネージャ統合無し |

---

## フェーズ構成

```
v1.x 強化（現在地→6ヶ月）
  ├─ A. スキーマ品質の底上げ
  ├─ B. テストピラミッドの完成
  ├─ C. 開発者体験（DX）の整備
  ├─ D. セキュリティ・サプライチェーン強化
  └─ E. ドキュメント・翻訳の完全化

v2 設計（6–12ヶ月）
  ├─ F. スキーマ進化と互換性の機械可読化
  ├─ G. 相互運用認定プログラム
  └─ H. マルチランタイム参照アーキテクチャ

普及・エコシステム（12ヶ月–）
  ├─ I. SDK・ライブラリ・ツールチェーン
  ├─ J. 実案件テンプレートと事例集
  └─ K. コミュニティ・ガバナンス
```

---

## A. スキーマ品質の底上げ（v1.x）

### 課題
- companion 9 種のうちベクトルでカバーされているのは `canonicalization_binding` と `validator_abi_binding` のみ
- スキーマ間に `$ref` を使った関係性表現がない（論理的関係はプロファイルの `schema_map` のみ）
- フィールド制約（format, pattern, minimum 等）が「型＋required」止まりのスキーマが多い

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| A-1 | 残り 7 companion の valid/invalid ベクタ追加 | 高 | `conformance/vectors/phase3/` に 14+ ファイル |
| A-2 | Core スキーマへの `format` / `pattern` / `minLength` 制約追加 | 中 | `schemas/core/*.schema.json` 更新 |
| A-3 | スキーマ間関係の明示化（`$ref` またはドキュメント） | 中 | `schemas/README.md` + 関係図 |
| A-4 | companion の「minimal surface」自己申告をリリース品質へ昇格 | 中 | `schemas/companion/` 更新 |

---

## B. テストピラミッドの完成（v1.x）

### 課題
- Phase1 に不変条件ケースがない（スキーマベクタのみ）
- Phase3 companion の構造検証が薄い
- E2E（トランスポート/ランタイムを含む）相互運用テストの仕組みがない

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| B-1 | Phase1 の不変条件ケース追加（agreement→revision→event の因果順序等） | 高 | `conformance/cases/phase1/` |
| B-2 | Phase3 companion の invalid ベクタ拡充 | 高 | `conformance/vectors/phase3/invalid/` |
| B-3 | フレーク検出（CI 上の再実行安定性テスト） | 中 | CI ワークフロー更新 |
| B-4 | 外部ランナーの E2E 統合テストフレームワーク設計 | 低 | 設計文書 |

---

## C. 開発者体験（DX）の整備（v1.x）

### 課題
- bundle 単独クローン時に `.github/workflows/` がない
- `package.json` / `pyproject.toml` / `Makefile` がなく、プロジェクトメタデータが README 手動運用
- examples の自動バリデーション手順が明示されていない
- 「5分で動かせる」クイックスタートが不足

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| C-1 | bundle 単体用 `.github/workflows/conformance.yml` の同梱 | 高 | `.github/workflows/` |
| C-2 | `Makefile` または `justfile` でワンコマンド操作を統一 | 中 | `Makefile` |
| C-3 | examples の自動バリデーションスクリプト追加 | 中 | `scripts/validate_examples.sh` |
| C-4 | 「5分クイックスタート」ドキュメント（日英） | 高 | `docs/*/20_quickstart.md`（番号は仮） |
| C-5 | `pyproject.toml` によるプロジェクトメタデータの標準化 | 低 | `pyproject.toml` |

---

## D. セキュリティ・サプライチェーン強化（v1.x）

### 課題
- ロックファイルがない（`requirements-conformance.txt` のピン留めのみ）
- Dependabot / Renovate による依存自動更新が未設定
- CodeQL / SAST の自動スキャンがない
- `pip-audit` は「あれば実行」で、CI 必須ではない

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| D-1 | `pip-compile` による `.lock` ファイル生成と CI 必須化 | 高 | `requirements-conformance.lock` |
| D-2 | Dependabot 設定ファイル追加 | 高 | `.github/dependabot.yml` |
| D-3 | CI に `pip-audit` を必須ステップとして追加 | 中 | ワークフロー更新 |
| D-4 | CodeQL / Semgrep による静的解析の導入 | 低 | `.github/workflows/codeql.yml` |
| D-5 | 署名付きリリース（タグ署名 / cosign） | 低 | リリースワークフロー |

---

## E. ドキュメント・翻訳の完全化（v1.x）

### 課題
- `15_実務インパクト整理.md` に日本語版がない
- `16_v1リリース実行計画.md` に英語版がない
- SDK 統合ガイド・本番ハーネス実装ガイドがない
- `schemas/README.md` の成熟度表記は更新済み

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| E-1 | `15_実務インパクト整理.md` 日本語版作成 | 中 | `docs/ja/15_実務インパクト整理.md` |
| E-2 | `16_v1リリース実行計画.md` 英語版作成 | 中 | `docs/en/16_v1リリース実行計画.md` |
| E-3 | 本番ハーネス実装ガイド（日英） | 高 | `docs/*/21_harness_implementation_guide.md` |
| E-4 | `schemas/README.md` の成熟度表記を現状に合わせて更新 | 低 | `schemas/README.md` |
| E-5 | `docs/README.md` のインデックスに新文書を追加 | — | 他タスクに連動 |

---

## F. スキーマ進化と互換性の機械可読化（v2 設計）

### 検討事項
- 現在の互換性ルールは `17_v1_release_policy.md` に人間言語で記述。機械的に検証できない
- v2 でフィールド追加・型変更が起きたとき、v1 レポートとの互換性をどう保証するか
- JSON Schema の `$id` にバージョンを含めるか（現状は `urn:acp:schemas:core:*_v1`）

### アクション
| # | タスク | 成果物 |
|---|--------|--------|
| F-1 | スキーマバージョニングポリシーの策定 | `docs/*/schema_versioning_policy.md` |
| F-2 | 互換性テスト（v1 レポートを v2 ハーネスで読めるか等） | テストスイート |
| F-3 | スキーマ changelog の自動生成（差分検出ツール） | `scripts/schema_diff.sh` |

---

## G. 相互運用認定プログラム（v2 設計）

### 検討事項
- 現在は `harness_contract_v1.json` と参照実装があるが、外部実装の「適合」を判定する公式プロセスがない
- 認定レベル（例: Level 1 = Phase1 pass, Level 2 = Phase2 pass, Level 3 = Phase3 + parity）の定義
- 認定バッジ / レジストリの運営

### アクション
| # | タスク | 成果物 |
|---|--------|--------|
| G-1 | 認定レベルの定義と公開 | `docs/*/conformance_certification.md` |
| G-2 | 認定テストスイートのパッケージ化（外部実装者が `npx` / `pip` で実行可能に） | パッケージ |
| G-3 | 適合実装レジストリ（GitHub Pages 等） | Web サイト |

---

## H. マルチランタイム参照アーキテクチャ（v2 設計）

### 検討事項
- ACP は「アカウンタビリティ層」であり、トランスポート/ランタイムは意図的にスコープ外
- しかし、採用者は「どう統合するか」の参照アーキテクチャを求める
- MCP / A2A / ワークフローエンジン / 決済レールとの **接続パターン** を示す必要がある

### アクション
| # | タスク | 成果物 |
|---|--------|--------|
| H-1 | 統合パターンカタログ（MCP + ACP, A2A + ACP 等） | `docs/*/integration_patterns.md` |
| H-2 | 参照実装（例: Python SDK + FastAPI アダプタ） | `examples/integrations/` |
| H-3 | トランスポート非依存の成果物交換プロトコル仕様 | 設計文書 |

---

## I. SDK・ライブラリ・ツールチェーン（普及）

### 検討事項
- 現在は JSON Schema + シェルスクリプト + Python リファレンスハーネスのみ
- 採用者が「コピペで使える」SDK がない
- バリデーション・成果物生成・レポート解析をプログラムから呼べる API が欲しい

### アクション
| # | タスク | 成果物 |
|---|--------|--------|
| I-1 | Python SDK（スキーマバリデーション + 成果物ビルダー + レポートパーサー） | `acp-sdk-python` パッケージ |
| I-2 | TypeScript/JavaScript SDK | `acp-sdk-js` パッケージ |
| I-3 | CLI ツール（`acp validate`, `acp report`, `acp diff`） | `acp-cli` |
| I-4 | VS Code 拡張（スキーマ補完 + バリデーション） | Marketplace 公開 |

---

## J. 実案件テンプレートと事例集（普及）

### 検討事項
- 現在の examples は最小理解用（2 バンドル）
- 採用者は「自分の業務にどう適用するか」を知りたい
- `15_実務インパクト整理.md` に業種別インパクトがあるが、対応する成果物テンプレートがない

### アクション
| # | タスク | 成果物 |
|---|--------|--------|
| J-1 | 業種別テンプレート（採用 / 外注制作 / リサーチ / マーケ / 社内マルチエージェント） | `examples/templates/` |
| J-2 | 導入事例集（匿名可）の収集と公開 | `docs/*/導入事例集.md` |
| J-3 | 「ACP を既存システムに1日で組み込む」チュートリアル | `docs/*/ACPを既存システムに1日で組み込む.md` |

---

## K. コミュニティ・ガバナンス（普及）

### 検討事項
- CONTRIBUTING.md / CODE_OF_CONDUCT.md / GOVERNANCE.md が未整備
- Issue テンプレート / PR テンプレートがない
- ライセンスの明示（現状 bundle 内にライセンスファイルが見当たらない）
- RFC / ADR（Architecture Decision Record）プロセスがない

### アクション
| # | タスク | 優先度 | 成果物 |
|---|--------|--------|--------|
| K-1 | LICENSE ファイルの追加（MIT / Apache-2.0 等） | **最高** | `LICENSE` |
| K-2 | CONTRIBUTING.md の作成 | 高 | `CONTRIBUTING.md` |
| K-3 | CODE_OF_CONDUCT.md の作成 | 高 | `CODE_OF_CONDUCT.md` |
| K-4 | Issue / PR テンプレート | 中 | `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` |
| K-5 | GOVERNANCE.md（意思決定プロセス、メンテナーの責務） | 中 | `GOVERNANCE.md` |
| K-6 | ADR（Architecture Decision Record）ディレクトリの導入 | 低 | `docs/adr/` |

---

## 優先順位マトリクス（推奨実行順）

```
最優先（今すぐ）
  K-1  LICENSE ファイル                      ← 公開に必須
  C-1  bundle 単体用 CI                     ← fork した人が動かせない
  D-1  ロックファイル生成                    ← 再現ビルドの基盤
  D-2  Dependabot                           ← 脆弱性の自動検知

高（1–2ヶ月）
  A-1  companion ベクタ拡充
  B-1  Phase1 不変条件ケース
  C-4  5分クイックスタート
  E-3  ハーネス実装ガイド
  K-2  CONTRIBUTING.md

中（3–6ヶ月）
  A-2  スキーマ制約強化
  B-2  Phase3 companion invalid 拡充
  C-2  Makefile
  C-3  examples 自動バリデーション
  D-3  pip-audit CI 必須化
  E-1  15_real_world_impact 日本語版
  E-2  16_release_execution_plan 英語版

v2 設計（6–12ヶ月）
  F-1〜F-3  スキーマバージョニング
  G-1〜G-3  認定プログラム
  H-1〜H-3  統合パターン

普及（12ヶ月–）
  I-1〜I-4  SDK / CLI / 拡張
  J-1〜J-3  テンプレート / 事例 / チュートリアル
  K-4〜K-6  テンプレート / ガバナンス / ADR
```

---

## 成熟度ダッシュボード

以下を定期的に更新し、プロジェクトの進捗を可視化します。

| 指標 | 現在値 | 目標（v1.x 完了時） | 目標（v2） |
|------|--------|---------------------|-----------|
| Core スキーマ制約カバー率 | 97.8%（136 項目中 133 項目に制約） | 80%+ | 95%+ |
| Companion ベクタカバー率 | 9/9（100%） | 9/9（100%） | 100% + 回帰 |
| 不変条件ケース数 | 13 | 25+ | 50+ |
| CI パイプライン | 親リポジトリ + bundle 単体 | bundle 単体 | + 外部ランナー矩阵 |
| ドキュメント日英対称率 | 10/10（100%、ルート docs） | 100% | 100% |
| 外部ハーネス適合実装数 | 0（自作のみ） | 1+ | 3+ |
| SDK 言語数 | 1（Python） | 1（Python） | 2+（Python + JS） |
| LICENSE | 設定済み | 設定済み | — |

---

## 次のアクション（提案）

1. **I-2**（TypeScript/JavaScript SDK の公開）
2. **I-4**（VS Code 拡張の公開）
3. **J-1**（業種別テンプレートの公開）

この3系統を進めることで、アーキテクチャ整備フェーズから SDK・拡張・導入テンプレートの普及フェーズへ移行しやすくなります。
