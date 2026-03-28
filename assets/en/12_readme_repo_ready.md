Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# ACP

ACP is an accountability layer for delegated AI work.

ACP is not an execution framework, not a transport protocol, and not a payment rail.

## What ACP Is
- Governed agreement/revision boundary for delegated work
- Signed causal append-only event history
- Evidence-bound verification model
- Explicit settlement intent model
- Dispute/freeze baseline for auditable review

## What ACP Is Not
- Runtime orchestration engine
- Agent-to-agent transport protocol
- Money movement rail
- Prompt wrapper

## Required Separations
- Prompt is not contract.
- Claim is not evidence.
- Verification is not settlement.

## Layering
| Layer | Responsibility | ACP scope |
|---|---|---|
| Communication | Message exchange | Out of scope |
| Execution | Planning/tool/runtime orchestration | Out of scope |
| Economic rail | Value movement/finality | Out of scope |
| Accountability | Authorization/evidence/verification/settlement/dispute | In scope |

## Core Artifacts
Core is fixed as 15 artifacts:
- `agreement_v1`
- `revision_v1`
- `event_v1`
- `evidence_pack_v1`
- `proof_artifact_v1`
- `verifier_descriptor_v1`
- `proof_finality_v1`
- `resource_reservation_v1`
- `delegation_edge_v1`
- `data_policy_binding_v1`
- `effective_policy_projection_v1`
- `time_fact_v1`
- `verification_report_v1`
- `settlement_intent_v1`
- `freeze_record_v1`

## Minimal Adoption Path
1. Wrap existing runtime with agreement/revision/event/evidence/verification artifacts.
2. Add replayable policy with explicit time facts.
3. Enforce delegation edge and reservation coverage before child activation.
4. Emit settlement intents as separate artifacts.
5. Add dispute/freeze branch.

## Conformance Status
Current status: Draft package / reference conformance baseline available.

Available now:
- Thin conformance adapter contract (`/conformance/harness_contract_v1.json`)
- Phase 1 profile and vector mapping (`/conformance/profiles/phase1.profile.json`)
- Phase 2 profile with invariant cases (`/conformance/profiles/phase2.profile.json`)
- Phase 3 profile with invariant cases (`/conformance/profiles/phase3.profile.json`)
- Repo-local reference harness (`/scripts/reference_harness.py`)
- External harness wrapper (`/scripts/conformance.sh`)
- CI gate wrapper (`/scripts/conformance_ci.sh`)
- Contract-test external runner (`/scripts/mock_external_runner.sh`)
- Split CI workflow with required reference gates (`/.github/workflows/conformance.yml`)

Release prerequisite outside this repo:
- Provide an actual external harness path via `ACP_HARNESS_RUNNER` for release/manual fail-closed gates

## Repository Layout
- `/schemas/core` core artifacts (Core-15)
- `/schemas/companion` binding/companion schemas
- `/schemas/meta` reason/status registries
- `/schemas/vectors` starter vectors and manifest
- `/examples` minimal and delegated workflow bundles
- `/conformance` adapter contract/profile/report schema
- `/scripts` conformance adapter entrypoint
- `/.github/workflows/conformance.yml` conformance gate workflow
- `/public` public-facing release docs

## Compatibility Position
ACP complements MCP, A2A, workflow engines, and payment systems by providing accountability semantics across them.

## Public Package Links
- Baseline: `assets/en/00_package_baseline.txt`
- Message map: `assets/en/01_message_map.md`
- Launch copy bank: `assets/en/02_launch_copy_bank.md`
- Demo script: `assets/en/03_demo_script_90s.md`
- Share FAQ: `assets/en/04_share_faq.md`
- Channel playbook: `assets/en/07_channel_playbook.md`
- Demo script (30s): `assets/en/08_demo_script_30s.md`
- Demo script (3min): `assets/en/09_demo_script_3min.md`
- Objection memo: `assets/en/13_objection_memo.md`
- Schema release plan: `assets/en/10_schema_release_plan.md`
- Use case: `assets/en/05_anchor_use_case.txt`
- Matrix: `assets/en/06_comparison_matrix_short.txt`
- FAQ (top 5): `assets/en/11_faq_top5.md`
- Issue packet: `assets/en/14_issue_submission_packet.md`
