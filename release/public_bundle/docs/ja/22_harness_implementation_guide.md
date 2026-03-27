# ACP ハーネス実装ガイド

このガイドは、`ACP_HARNESS_RUNNER` として動く本番ランナーの最小契約を定義します。

## 目的

本番ハーネスは、リポジトリ内の reference harness ではなく、ACP conformance を実行する実体です。contract、profile、request を読み、schema に一致する report を書き出す必要があります。

## 必須 CLI 引数

ランナーは次の引数を受け取る必要があります。

- `--contract <path>`
- `--profile <path>`
- `--request <path>`
- `--report <path>`

推奨動作:

- 必須引数が1つでも欠けたら non-zero で終了する。
- 未知のフラグは、明示的に対応しない限りエラーにする。
- 標準入力に依存せず、最終 report を stdout に出さない。

## 入力の読み込み

渡された path をそのまま使います。

- 最初に contract を読み、report 形状とハーネス要求を把握する。
- 次に profile を読み、vector / schema_map / cases を解決する。
- 最後に request を読み、実行要求と出力先を確定する。
- CI から起動される前提なら、相対 path は current working directory ではなく repo root / bundle root 基準で解決する。

実務ルール:

- 入力が欠落・読込不可・不正 JSON なら即失敗する。
- 反復実行で report 形状が変わらないよう、決定的な順序で処理する。

## Report 要件

`--report` に書く JSON は `conformance/report.schema.json` に一致させます。

最低限、次を含めます。

- `run_id`
- `profile_id`
- `status`
- `generated_at`
- `summary`
- `results`

結果は、判定とメッセージが追跡できる安定した形にします。

推奨 status:

- 期待どおりにすべて一致したら `pass`
- 実行は完了したが期待不一致があれば `fail`
- 契約そのものが完了しなければ `error`

## Fail-Closed

ACP の release gate は fail-closed です。

- 入力が読めなければ non-zero で終了する。
- report を書けなければ non-zero で終了する。
- 必要な依存や機能が欠けているときは、成功 report を捏造しない。
- 非対応 profile / request を受けたら、失敗を明示して non-zero で終了する。

ハード失敗を silent success に変えないこと。

## Mock と Production

mock は配線確認だけに使います。

- mock mode はスクリプト配線と path の確認に限定する。
- production mode は実際のハーネス処理を実行し、選択した profile を検証する。
- mock の出力を production evidence として流用しない。
- reference 実装と production 実装は分離し、repo-local baseline を相互運用の権威にしない。

## 最小テスト

本番ランナーを release や CI で使う前に、次を確認します。

- 実行ファイルに権限がある。
- `--contract` / `--profile` / `--request` / `--report` が end-to-end で動く。
- 生成 report が `conformance/report.schema.json` に一致する。
- 既知の pass profile で `pass` を返す。
- 既知の fail vector / case で `fail` または `error` を返す。
- 必須入力欠落時に non-zero で終了する。

## 統合メモ

- CI で証跡を保存しやすいよう、report path は決定的にする。
- 失敗調査に必要なログは残しつつ、JSON report に人間ログを混ぜない。
- 既存ランタイムを包む場合は、ACP harness contract を壊さない薄い adapter にする。
