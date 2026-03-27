# ACP (AI Contract Protocol)

ACP は、委任された AI 作業のための説明責任レイヤです。

ACP は実行フレームワークでも、トランスポートプロトコルでも、決済レールでもありません。

## ACP が提供するもの

- 委任作業における、合意/改訂の統制境界
- 署名付き因果追跡が可能な追記専用イベント履歴
- 証拠に紐づく検証モデル
- 明示的な清算意思（settlement intent）モデル
- 監査可能なレビューのための争議/凍結ベースライン

## ACP が提供しないもの

- 実行オーケストレーションエンジン
- エージェント間トランスポートプロトコル
- 資金移動レール
- プロンプトラッパー

## 必須の分離原則

- Prompt は contract ではない
- Claim は evidence ではない
- Verification は settlement ではない

## レイヤ構造

| Layer | Responsibility | ACP scope |
| --- | --- | --- |
| Communication | メッセージ交換 | 対象外 |
| Execution | 計画/ツール/ランタイムのオーケストレーション | 対象外 |
| Economic rail | 価値移転/ファイナリティ | 対象外 |
| Accountability | 認可/証拠/検証/清算/争議 | 対象 |

## コア成果物

Core は 15 成果物で固定されています:

- `agreement_v1`
- `revision_v1`
- `event_v1`
- `evidence_pack_v1`
- `proof_artifact_v1`
- `verifier_descriptor_v1`
- `proof_finality_v1`
- `resource_reservation_v1`
- `delegation_edge_v1`
- `data_policy_binding_v1`
- `effective_policy_projection_v1`
- `time_fact_v1`
- `verification_report_v1`
- `settlement_intent_v1`
- `freeze_record_v1`

## 最小導入パス

1. 既存ランタイムを、agreement/revision/event/evidence/verification 成果物でラップする
2. 明示的な time fact を使って再生可能なポリシーを追加する
3. 子アクティベーション前に delegation edge と reservation coverage を強制する
4. settlement intent を独立した成果物として出力する
5. dispute/freeze 分岐を追加する

## 適合性ステータス

現在の状態: ドラフトパッケージ / 参照適合性ベースラインあり。

現時点で利用可能:

- リポジトリローカルの conformance アダプタ契約 (`/conformance`)
- Phase 1/2/3 プロファイルと schema vectors / invariant cases
- リポジトリローカル参照ハーネス (`/scripts/reference_harness.py`)
- mock/reference/external モードに分割された CI ゲート
- 外部ハーネスランナー用ラッパー (`/scripts/conformance.sh`)

このリポジトリ外で必要なリリース前提:

- リリース/手動 fail-closed ゲート向けに、`ACP_HARNESS_RUNNER` へ実際の external harness パスを提供する

## リポジトリ構成

- `/schemas/core` core schema 一式 (Core-15 coverage)
- `/schemas/companion` binding/companion schema
- `/schemas/meta` reason code と status register
- `/schemas/vectors` valid/invalid starter vector
- `/examples` minimal-task / delegated-research バンドル
- `/conformance` 薄い harness 契約/profile/report schema
- `/docs` 公開可能な EN/JA ドキュメント一式
- `/public` ローンチ/公開向けアセット
- `/sdk` SDK 実装 (`js`, `python`)
- `/scripts` conformance アダプタのエントリポイント
- `/release/public_bundle` 公開専用バンドル資産
- `/vendor` ローカル専用の third-party / vendored ツリー (ACP 配布リポジトリから除外)
- `/pyproject.toml` リポジトリレベル Python プロジェクトメタデータ (`[project.optional-dependencies].conformance`)

## GitHub 公開と再現性

- GitHub へ公開する場合は、`/schemas`、`/conformance`、`/docs`、`/examples`、`/scripts`、`/sdk`（生成依存は除く）、`/public`、`/release/public_bundle`、およびルートの運用ファイルを追跡対象としてアップロードします。
- `.gitignore` にあるローカル専用/生成物（例: `.tmp/`、`node_modules/`、Python キャッシュ、ローカル venv、ローカル専用 vendored ツリー）はアップロードしません。
- 再現性の目標は「クリーン clone 後に lock ファイル（`requirements-conformance.lock`、`sdk/js/acp-sdk-js/package-lock.json`）から依存を再インストールし、README 記載コマンドで検証を再実行できること」です。
- 例外として、本番 external harness の挙動再現には独自の `ACP_HARNESS_RUNNER` が必要です（本リポジトリには mock/reference のベースラインのみ含まれます）。

## `vendor/` に入れる代表例

- ローカル検証や互換性確認のために同梱する、固定バージョンの第三者ソーススナップショット（例: 上流ツールの pin 版ツリー）。
- 内部テストでのみ必要なローカルパッチ/フォーク（ACP 配布成果物に含めないもの）。
- 生成バイナリ、パッケージキャッシュ、ビルド出力は `vendor/` ではなく、`.gitignore` 対象の一時/出力パスで管理します。

## 互換性ポジション

ACP は MCP、A2A、ワークフローエンジン、決済システムを置き換えるものではなく、これらを横断した説明責任セマンティクスを提供して補完します。

## 公開補助ドキュメント

- `public/README.txt`

## プロジェクトガバナンス

- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `GOVERNANCE.md`
- `DISTRIBUTION_SCOPE.md` (公開時に何を含める/除外するか)

## ローンチ面の資料

- `public/01_message_map.md`
- `public/02_launch_copy_bank.md`
- `public/03_demo_script_90s.md`
- `public/04_share_faq.md`
- `public/07_channel_playbook.md`
- `public/08_demo_script_30s.md`
- `public/09_demo_script_3min.md`
- `public/13_objection_memo.md`
- `./scripts/public_release_check.sh` は公開メッセージのガードレールを検証します（**ripgrep** `rg` が必要。macOS: `brew install ripgrep`）
- `./scripts/prepare_public_bundle.sh` は配布専用バンドルを生成します

## Conformance Adapter クイックスタート

- `./scripts/install_conformance_deps.sh`（`requirements-conformance.lock` を優先し、lock が無い場合は `requirements-conformance.txt` にフォールバック）
- `make doctor`
- `make validate-examples`
- `./scripts/conformance.sh doctor`
- `./scripts/conformance.sh prepare`
- `./scripts/conformance.sh run --mock`
- `./scripts/conformance.sh run --reference`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=./scripts/mock_external_runner.sh ./scripts/conformance.sh run`

## Conformance CI ゲート

- `ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `.github/workflows/conformance.yml` には push/PR/manual の実行エントリがあります
- `.github/workflows/codeql.yml` は push/PR/schedule で CodeQL 静的解析を実行します
- `.github/workflows/release-sign.yml` は署名付き annotated release tag を必須化し、cosign 署名済みチェックサム成果物を release にアップロードします
- `./scripts/cross_version_compat.sh` はクロスバージョンの report 互換性チェック（v1 fixture + 生成 report）を実行します
- `./scripts/schema_diff.sh --old <ref-or-dir> --new <ref-or-dir>` は互換性分類付き schema changelog を生成します
- `./scripts/render_conformance_registry.sh` は `docs/registry/index.html` を `docs/registry/implementations.json` からレンダリングします
- `./scripts/conformance_selftest.sh` は mock/reference/contract-smoke/negative-path の確認を実行します
- `make conformance-mock`
- `make conformance-reference`
- `make conformance-phase1`
- `make conformance-phase2`
- `make conformance-phase3`
- `make cross-version-compat`
- `make schema-diff-last`

## Examples 検証

- `./scripts/validate_examples.sh`
- `make validate-examples`

## External Runner について

- `scripts/mock_external_runner.sh` は契約テスト用ユーティリティです
- これはプロトコル検証器ではなく、external harness 実装の代替ではありません
- `scripts/reference_harness.py` はリポジトリローカルのベースラインであり、external 展開における相互運用性の最終権威ではありません

## ライセンス

- `Apache-2.0` (`./LICENSE`)

## リリース署名

- リリースには **署名付き annotated tag** を作成してください（未署名タグや lightweight tag は `.github/workflows/release-sign.yml` で拒否されます）
- release-sign workflow は `acp-<tag>.tar.gz` を作成し、SHA256 を生成して keyless cosign でチェックサムへ署名し、署名/証明書成果物を release へアップロードします

## ACP external harness と同梱 Atrakta (0.14.1) の違い

- `ACP_HARNESS_RUNNER` は `/conformance` に記載された harness CLI 契約（例: `--contract`, `--profile`, `--request`, `--report`）を満たす実行可能ファイルである必要があります
- 同梱の `vendor/atrakta_0.14.1/` はローカルランタイム検証（`./vendor/atrakta_0.14.1/scripts/dev/verify_loop.sh`）向けの別 Go プロダクトです。専用アダプタを実装しない限り、その `atrakta` CLI は `ACP_HARNESS_RUNNER` の置き換えにはなりません
- リポジトリゲートはドキュメントの通り `--mock` / `--reference` / `mock_external_runner.sh` を使用してください。本番 external conformance には独自 harness または adapter バイナリが必要です
