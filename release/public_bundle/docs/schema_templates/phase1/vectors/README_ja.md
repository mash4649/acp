# Phase 1 Conformance Vectors（日本語）

このフォルダは Phase 1 スキーマ向けのスターターベクタを提供します。

## 構成
- `valid/`: スキーマ検証に通る想定のサンプル
- `invalid/`: スキーマ検証に失敗する想定のサンプル
- `vector-manifest.json`: 各ベクタと期待結果の一覧

## 想定利用
各ベクタを `docs/schema_templates/phase1/core/` の対応スキーマに対して実行してください。

## スコープ注記
これらのベクタは構造的なスキーマ適合のみを検証します。プロトコル不変条件全体は検証しません。
