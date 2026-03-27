# トランスポート非依存の成果物交換プロトコル

この文書は、システム間で ACP artifact を交換するためのトランスポート非依存プロトコルを定義します。

## スコープ

このプロトコルが定義するもの:

- 成果物交換パッケージの構造
- manifest の必須項目と検証要件
- 完全性検証とリプレイ要件
- 受信側のステータスと応答セマンティクス

このプロトコルが定義しないもの:

- ランタイムオーケストレーション
- メッセージ輸送方式（HTTP / MQ など）
- payment / settlement rail の実行仕様

## 設計目標

- 成果物交換を決定的かつ replay 可能にする。
- transport / runtime の選択を中核仕様から分離する。
- append-only のアカウンタビリティ履歴を保持する。
- 最小前提で独立検証できる形にする。

## 交換単位

交換単位は **Artifact Exchange Package (AEP)** とします。

AEP は、次を含むディレクトリまたはアーカイブです。

- `manifest.json`
- `artifacts/`（ACP artifact JSON）
- `checksums.sha256`
- 任意の `signature/` ディレクトリ

## 必須パッケージ構造

```text
<package>/
  manifest.json
  checksums.sha256
  artifacts/
    agreement.json
    revision.json
    event.activation.json
    evidence_pack.json
  signature/                    # optional
    checksums.sha256.sig
    checksums.sha256.pem
```

## Manifest 仕様（Protocol v1）

必須トップレベル項目:

- `protocol_version`: 文字列（`"aep-v1"`）
- `exchange_id`: このパッケージの一意 ID
- `generated_at`: RFC3339 timestamp
- `producer`: 生成側識別子
- `artifacts`: artifact descriptor 配列

各 artifact descriptor の必須項目:

- `path`: `artifacts/` 配下の相対 path
- `artifact_type`: ACP artifact type（例: `agreement_v1`）
- `artifact_id`: 該当 artifact の識別子値
- `sha256`: ファイルバイトのチェックサム

任意項目:

- `previous_exchange_id`: append-only の連鎖参照
- `profile_id`: conformance profile 文脈
- `notes`: producer メモ配列

## 検証ルール

受信側は次を実行する必要があります。

1. `manifest.json` が存在し、JSON として読めることを確認する。
2. manifest 必須項目が揃っていることを確認する。
3. 一覧化された artifact ファイルが存在することを確認する。
4. `manifest.json` と `checksums.sha256` の双方で checksum を照合する。
5. checksum 不一致があれば受理しない。
6. 利用前に各 artifact を対応 ACP schema で検証する。

署名ファイルがある場合は、証跡として信頼する前に署名検証を行います。

## Replay と順序

- パッケージは append-only とし、過去パッケージを改変しない。
- `previous_exchange_id` がある場合は、既知パッケージを参照している必要がある。
- 因果順序は transport timestamp ではなく、ACP artifact（`event_v1` / `revision_v1` / edge）から復元する。

## ステータスと応答

受信側はパッケージごとに次のいずれかを返すことを推奨します。

- `accepted`: 完全性検証と schema 検証を通過
- `rejected`: 完全性または schema 検証で失敗
- `incomplete`: 構造は妥当だが要求された verification には不足

推奨応答ペイロード:

- `exchange_id`
- `status`
- `processed_at`
- `reasons`（安定した理由文字列配列）

## 障害セマンティクス

- 完全性失敗時: reject し、監査用に元バイト列を保持する。
- schema 失敗時: reject し、artifact path と検証理由を返す。
- 部分不足時: accept を捏造せず `incomplete` を返す。

## 互換性

- 将来改訂では `protocol_version` を新値にする。
- `manifest.json` の加法的フィールド追加は、未知キーを無視できれば forward-compatible とする。
- 必須項目削除や必須意味の変更は breaking とする。

## 最小相互運用チェック

- 生成側が決定的 checksum を持つ AEP を出力できる。
- 受信側が checksum / schema を fail-closed で検証できる。
- 受信側が交換された artifact から最低 1 本の agreement→revision→event 連鎖を replay できる。
- exchange_id が一意で、ログで追跡可能である。

## まとめ

AEP v1 は、ACP の責務境界と replay 性を維持しながら、トランスポート非依存で検証可能な成果物交換を実現する最小仕様です。
