# ACP を既存システムに1日で組み込む

このチュートリアルは、既存システムへ ACP を 1 日で導入するための最小手順を示します。

## 1. 1つの業務フローを選ぶ
まず、境界が明確なフローを 1 つだけ選びます。例えば:
- 採用レビュー
- 外注制作
- 調査・検証
- マーケティング承認
- 社内マルチエージェントの委任

最初から全社モデルを作ろうとせず、1つの契約境界に絞ります。

## 2. 最小限の artifact を決める
初回導入では、必要な artifact だけを使います。
- `agreement_v1` で契約境界を表す
- `revision_v1` で変更を追う
- `event_v1` で causal な起点を記録する
- レビュー証跡が必要なら `evidence_pack_v1` または `verification_report_v1`
- 委任や受け渡し制御が必要なら `delegation_edge_v1` / `resource_reservation_v1` / `settlement_intent_v1`

## 3. 既存の example から始める
近い starter bundle を `examples/` からコピーします。
- `examples/minimal-task/`
- `examples/delegated-research/`
- `examples/templates/`

その後、ID と日時を業務に合わせて置き換えます。

## 4. ローカルで検証する
コピーした bundle を例示用の検証スクリプトで確認します。

```bash
./scripts/validate_examples.sh examples/minimal-task
```

検証に失敗したら、新しいフローを足す前に artifact の形を直します。

## 5. 最初の運用ルールを 1 つだけ足す
最初に効くルールはたいてい次のどれかです。
- parent agreement なしでは child work を開始しない
- review 前に evidence を必ず添付する
- delegation の前に reservation を作る
- settlement intent は verification と分離して明示する

最初は手作業でも運用できるくらい単純にしておきます。

## 6. 段階的に広げる
最初のフローが動いたら、次を追加します。
- もう 1 つ workflow を足す
- artifact の対応表を明文化する
- 承認境界を常に明示する

ACP は、最初の導入を小さく、見える形で、監査可能にすると広げやすくなります。
