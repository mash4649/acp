Status: Draft
Type: Normative
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# Schema Release Plan (Core-15 Preserving)

## Rule
Publication can be phased. Core definition cannot be phased.

## Core Set (fixed)
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
Target: explainable delegated-work flow with explicit separation.

Schemas to publish (concrete files):
- /schemas/core/agreement_v1.schema.json
- /schemas/core/revision_v1.schema.json
- /schemas/core/event_v1.schema.json
- /schemas/core/evidence_pack_v1.schema.json
- /schemas/core/verification_report_v1.schema.json
- /schemas/core/settlement_intent_v1.schema.json
- /schemas/core/freeze_record_v1.schema.json
- /schemas/meta/reason-codes.json
- /schemas/meta/status-registers.json

Gate checks:
- Canonicalization declared
- Revision binding enforced
- Verification and settlement separated
- Freeze commitment fields present
- Decision vocabulary aligns with reason-codes registry
- Phase 1 vector bundle passes expected outcomes:
  - `docs/en/schema_templates/phase1/vectors/valid/*` => pass
  - `docs/en/schema_templates/phase1/vectors/invalid/*` => fail

## Phase 2: Delegation/Policy Safety
Target: safe child activation and replayable policy surface.

Schemas to publish (concrete files):
- /schemas/core/resource_reservation_v1.schema.json
- /schemas/core/delegation_edge_v1.schema.json
- /schemas/core/data_policy_binding_v1.schema.json
- /schemas/core/effective_policy_projection_v1.schema.json
- /schemas/core/time_fact_v1.schema.json

Gate checks:
- Acyclic delegation checks representable
- Reservation coverage representable
- Policy projection inputs explicit
- Time guards consume explicit time facts

## Phase 3: Proof Surface + Companion Bindings
Target: proof abstraction coverage and high-assurance integration hooks.

Schemas to publish (concrete files):
- /schemas/core/proof_artifact_v1.schema.json
- /schemas/core/verifier_descriptor_v1.schema.json
- /schemas/core/proof_finality_v1.schema.json
- /schemas/companion/canonicalization_binding_v1.schema.json
- /schemas/companion/signature_envelope_binding_v1.schema.json
- /schemas/companion/trust_registry_binding_v1.schema.json
- /schemas/companion/validator_abi_binding_v1.schema.json
- /schemas/companion/policy_runtime_abi_binding_v1.schema.json
- /schemas/companion/dispute_process_binding_v1.schema.json
- /schemas/companion/transparency_binding_v1.schema.json
- /schemas/companion/oracle_market_binding_v1.schema.json
- /schemas/companion/streaming_settlement_binding_v1.schema.json

Gate checks:
- Proof verification status not collapsed into acceptance
- Proof finality semantics explicit
- Binding-specific internals remain outside Core schema semantics

## Non-goals of this plan
- Redefining Core as subset by phase
- Rail-specific settlement logic in Core schemas
- Universal ontology embedding in Core schemas
