# アンカー事例: 委任リサーチメモ（日本語）

## この事例の意図
delegation、証拠、検証、精算の分離、紛争/凍結を1本の短い流れで示し、ACPをペイメント/実行プロトコルとして誤解させません。

## 参加者
- Requester
- Provider collective
- Child research agent
- Verifier
- Settlement adapter

## アーティファクトフロー
- agreement_v1 / revision_v1
- delegation_edge_v1 + resource_reservation_v1
- event_v1 の連鎖
- evidence_pack_v1
- verification_report_v1
- settlement_intent_v1
- freeze_record_v1（紛争時）

## 正常系
1. 親 revision が有効化される
2. reservation coverage を満たした状態で child delegation を開始
3. 証拠パック を提出
4. 検証 が ACCEPT または PARTIAL_ACCEPT を返す
5. 精算意図を別途出力

## 紛争系
1. `dispute.opened` イベント発行
2. `freeze_record` が state/証拠/event の基準点をコミット
3. 精算意図を 保留またはブロック
4. 解決結果は新規イベントとして追記（既存成果物は不変）
