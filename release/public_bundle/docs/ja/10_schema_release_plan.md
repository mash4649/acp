# スキーマ公開計画（Core-15 維持・日本語）

## ルール
公開は段階化してもよいですが、Core 定義は段階化しません。

## Core Set（固定）
- agreement_v1
- revision_v1
- event_v1
- evidence_pack_v1
- proof_artifact_v1
- verifier_descriptor_v1
- proof_finality_v1
- resource_reservation_v1
- delegation_edge_v1
- data_policy_binding_v1
- effective_policy_projection_v1
- time_fact_v1
- verification_report_v1
- settlement_intent_v1
- freeze_record_v1

## Phase 1: Accountability Minimum
目的: 分離原則が明確な委任作業フローを説明可能にします。

公開対象（具体ファイル）:
- `/schemas/core/agreement_v1.schema.json`
- `/schemas/core/revision_v1.schema.json`
- `/schemas/core/event_v1.schema.json`
- `/schemas/core/evidence_pack_v1.schema.json`
- `/schemas/core/verification_report_v1.schema.json`
- `/schemas/core/settlement_intent_v1.schema.json`
- `/schemas/core/freeze_record_v1.schema.json`
- `/schemas/meta/reason-codes.json`
- `/schemas/meta/status-registers.json`

ゲート:
- canonicalization 宣言あり
- revision binding 強制
- 検証 / 精算 分離
- freeze commitment 項目あり
- reason-codes と語彙整合
- Phase 1 ベクタ の期待結果一致
 - `docs/ja/schema_templates/phase1/vectors/valid/*` は pass
 - `docs/ja/schema_templates/phase1/vectors/invalid/*` は fail

## Phase 2: Delegation/Policy Safety
目的: 安全な child activation と再実行可能なポリシー面を整えます。

公開対象:
- `/schemas/core/resource_reservation_v1.schema.json`
- `/schemas/core/delegation_edge_v1.schema.json`
- `/schemas/core/data_policy_binding_v1.schema.json`
- `/schemas/core/effective_policy_projection_v1.schema.json`
- `/schemas/core/time_fact_v1.schema.json`

ゲート:
- delegation 非循環表現が可能
- reservation coverage 表現が可能
- ポリシー projection 入力が明示
- time guard が明示 time facts を消費

## Phase 3: Proof Surface + Companion Bindings
目的: proof 抽象を網羅し、高保証な統合フックを提供します。

公開対象:
- `/schemas/core/proof_artifact_v1.schema.json`
- `/schemas/core/verifier_descriptor_v1.schema.json`
- `/schemas/core/proof_finality_v1.schema.json`
- `/schemas/companion/canonicalization_binding_v1.schema.json`
- `/schemas/companion/signature_envelope_binding_v1.schema.json`
- `/schemas/companion/trust_registry_binding_v1.schema.json`
- `/schemas/companion/validator_abi_binding_v1.schema.json`
- `/schemas/companion/policy_runtime_abi_binding_v1.schema.json`
- `/schemas/companion/dispute_process_binding_v1.schema.json`
- `/schemas/companion/transparency_binding_v1.schema.json`
- `/schemas/companion/oracle_market_binding_v1.schema.json`
- `/schemas/companion/streaming_settlement_binding_v1.schema.json`

ゲート:
- proof 検証ステータスと 受理 を混同しない
- proof finality 意味論を明示
- binding 固有の内部表現を Core 意味論に混ぜない

## 非目標
- phase ごとに Core を部分集合へ再定義すること
- rail 固有の 精算 ロジックを Core に入れること
- 汎用オントロジーを Core に埋め込むこと
