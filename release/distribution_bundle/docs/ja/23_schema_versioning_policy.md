# ACP スキーマバージョニングポリシー

この文書は、ACP スキーマ進化時の互換性ルールを定義します。

## 目的

ACP のスキーマは、実装者が仕様を読み直さなくても安全に採用できるか判断できるように version 管理します。

## バージョニングモデル

ACP の schema 識別子は、安定した artifact 名と semantic version ラベルで管理します。

推奨する machine-readable フィールド:

- `schema_id`: 安定した論理 ID
- `schema_version`: 公開 version 文字列
- `compatibility_class`: `compatible` / `forward-compatible` / `breaking`
- `deprecation_until`: 任意の廃止期限
- `supersedes`: 任意の後継 schema 参照

## 許容される変更

同一 major 系で通常許容される変更:

- 任意項目の追加
- 既存 consumer が未知値を無視できる前提での enum 値追加
- validation 行動を変えない説明文の更新
- required semantics を変えない metadata 項目の追加

## 許容されない変更

次の変更は breaking です。新しい major version または移行経路が必要です。

- required field の削除
- field type や required 個数の変更
- 既存の valid data を invalid にする enum の変更
- backward-compatible alias なしの field rename
- 以前 valid だった instance を落とす制約強化

## 廃止期間

field や schema を廃止する場合:

- 旧形式は少なくとも 1 回の公開 release cycle、または 90 日の長い方を維持する
- 後継を docs と machine-readable metadata に明記する
- 廃止期間が終わるまで validation と移行手順を残す

## CI チェック

schema 変更で推奨するチェック:

- Draft 2020-12 で全 schema を検証する
- 更新後 schema に対して valid / invalid vector を全件実行する
- breaking change は明示ラベルと version bump を必須にする
- 必要な移行メモや廃止メモが無い schema 変更は CI で落とす
- review では schema diff を比較し、意図した破壊的変更を可視化する

## リリース規則

変更が breaking なら、silent patch として出荷しない。

どちらかを選ぶ:

- 新しい major version を公開する
- 互換 shim と移行期間を文書化して提供する

## まとめ

基本ルールは保守的です。release plan に明示がない限り互換性を維持します。
