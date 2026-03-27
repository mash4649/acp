# 配布対象の整理（GitHub公開向け）

このファイルは、`project/` を GitHub リポジトリとして公開する際の「配布するもの / しないもの」の判断基準です。

## 配布するもの（追跡対象）

- `schemas/`（ACP スキーマ本体）
- `conformance/`（適合性プロファイル・ベクトル・成果物仕様）
- `docs/`（英日ドキュメント）
- `examples/`（サンプル）
- `scripts/`（検証/ビルド/配布スクリプト）
- `sdk/`（SDK 実装ソース）
- `public_assets/`（公開向け資料）
- `release/distribution_bundle/`（公開用バンドル定義）
- ルートの運用ファイル（`README.md`, `LICENSE`, `CONTRIBUTING.md` など）

## 配布しないもの（`.gitignore` 対象）

- `.tmp/`（一時出力・ローカル依存キャッシュ）
- `sdk/js/acp-sdk-js/node_modules/`（npm 依存）
- Python/Node のキャッシュ・一時ファイル（`__pycache__/`, `.pytest_cache/`, `.ruff_cache/` など）
- `vendor/atrakta_0.14.1/`（ローカル検証用途の同梱プロダクト）

## 補足

- 非配布物の具体パターンは `project/.gitignore` に集約しています。
- `vendor/` は「参照・検証のためにローカル保持するが、ACP 配布リポジトリには含めない」領域です。
