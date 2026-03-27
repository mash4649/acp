# ACP Conformance 認定

この文書は、外部 ACP 実装の認定モデルを定義します。

## 目的

認定は、実装が ACP conformance profile に対してどこまで検証済みかを利用者に伝えます。

## 認定レベル

### L1 - Phase 1 基準

L1 は、実装が Phase 1 の structural profile を通過した状態です。

必要な証跡:

- Phase 1 の reference または external report
- valid vector がすべて pass
- invalid vector が期待どおり fail
- report schema 違反がないこと

### L2 - Phase 1 + Phase 2

L2 は、実装が Phase 1 と Phase 2 の profile を通過した状態です。

必要な証跡:

- L1 の証跡
- case-based invariant を含む Phase 2 report
- causal order と reservation 系ケースの安定した処理

### L3 - Phase 1 + Phase 2 + Phase 3

L3 は、3 つすべての profile と proof surface binding の検証を通過した状態です。

必要な証跡:

- L2 の証跡
- companion binding coverage を含む Phase 3 report
- proof surface の整合チェック

## Badge の意味

badge は、獲得した level と時点を正確に示す必要があります。

推奨ラベル:

- `ACP Conformance L1`
- `ACP Conformance L2`
- `ACP Conformance L3`

badge のルール:

- badge には必ず日付または renewal marker を付ける
- badge は証跡 report か registry entry にリンクする
- certified level を超えた coverage を暗示しない

## Renewal

次のいずれかが変わったら認定を更新する:

- 実装に実質的な変更が入った
- profile version が変わった
- report schema が変わった
- conformance contract が変わった

推奨更新頻度:

- release ごとに再検証する
- 公開中の claim は少なくとも 90 日ごとに再検証する

## Revocation

次の場合は認定を取り消すか停止する:

- 実装が認定 level を満たさなくなった
- 証跡 report が古い、または検証不能
- breaking change により過去の certificate が無効化された
- 実装が level を誤表示した

## 透明性モデル

公開認定レコードには次を含める:

- 実装名
- 認定 level
- 対象 profile version
- 証跡 report へのリンク
- 発行日と更新日
- revocation 状態

最小限の public registry で十分です。目的は手続き増加ではなく追跡可能性です。

## CI と Registry のチェック

認定ツールに推奨するチェック:

- `conformance/report.schema.json` で report を検証する
- certificate が実際に使った profile version を参照していることを確認する
- claim level と証跡範囲が一致していることを確認する
- 証跡が欠落、古い、不整合なら失敗させる
- registry entry は renewal または revocation status 以外では不変にする

## Registry 公開

適合実装レジストリは次を公開元にします。

- `docs/registry/implementations.json`（機械可読ソース）
- `docs/registry/index.html`（人間向けページ）
- `scripts/render_conformance_registry.sh`（生成スクリプト）

運用手順: `docs/ja/28_conformant_implementation_registry.md`

## まとめ

認定は、検証範囲を隠さずに claim を素早く信頼できるようにするためのものです。
