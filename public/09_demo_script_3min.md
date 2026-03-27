Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# ACP 3-Minute Demo Script

## Goal
Give enough technical depth for researchers and implementers while staying non-replacement.

## Segment 1 (0:00-0:40) Category framing
- "ACP is an accountability layer for delegated AI work."
- "ACP is not execution, not transport, not payment rail."
- State three separations:
  - prompt is not contract
  - claim is not evidence
  - verification is not settlement

## Segment 2 (0:40-1:30) Core artifact flow
- Start with `agreement_v1` and `revision_v1`.
- Add append-only `event_v1` chain.
- Attach `evidence_pack_v1`.
- Show `verification_report_v1` outcome as a distinct artifact.
- Show `settlement_intent_v1` as a separate decision layer.

## Segment 3 (1:30-2:20) Delegation safety
- Open child work via `delegation_edge_v1`.
- Enforce `resource_reservation_v1` before activation.
- Explain `data_policy_binding_v1`, `effective_policy_projection_v1`, `time_fact_v1` as replay inputs.

## Segment 4 (2:20-3:00) Dispute and interop close
- Trigger dispute path and emit `freeze_record_v1`.
- Explain immutability: prior artifacts remain unchanged, resolution is appended.
- Close: "ACP complements MCP, A2A, workflow engines, and payment rails with accountability semantics."

## Demo source files
- `examples/minimal-task/*`
- `examples/delegated-research/*`
- `schemas/core/*`
- `conformance/profiles/phase1.profile.json`

## Presenter guardrails
- Do not pitch ACP as a universal agent protocol.
- Do not collapse proof verification and settlement release.
- Do not imply ACP includes message transport.
