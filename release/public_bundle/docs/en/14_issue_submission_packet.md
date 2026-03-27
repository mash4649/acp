Status: Draft
Type: Discussion
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# Issue Submission Packet

## Copy-Paste Title
Discussion: Minimal Accountability Layer for Delegated AI Work (Non-Replacement Scope)

## Copy-Paste Body
We propose discussing a narrow interoperability boundary for delegated AI workflows: an accountability layer that complements existing transport, execution, and payment systems.

This is not a replacement proposal for any of those systems. Scope is limited to accountable semantics: authorization under immutable revision, evidence submission, verification outcomes, settlement intent outcomes, and dispute/freeze commitments.

Why this discussion now:
- delegated AI workflows increasingly involve multi-step, multi-actor execution
- operational traces alone are insufficient for cross-stack accountability
- teams need replayable, implementation-independent boundary semantics

Layering target:
- communication protocols: message exchange
- execution frameworks: planning/tool orchestration
- payment rails: value movement/finality
- accountability layer: contract/evidence/verification/settlement/dispute semantics

Required separations:
- prompt is not contract
- claim is not evidence
- verification is not settlement

Proposed discussion units:
1. signed causal append-only event history
2. verification/settlement semantic separation
3. replayable policy evaluation with explicit inputs
4. safe child activation (delegation DAG safety + reservation coverage)
5. dispute/freeze semantics

Already-fixed baseline decisions for this packet:
- proof abstraction is in core scope
- delegation DAG safety and reservation safety are in core scope
- effective policy projection and explicit time facts are in core accountability surface
- dispute/freeze is a core hook

Requested focus:
Please comment on minimum interoperable representations (field groups and vocabularies), not on replacing existing protocols or reopening fixed scope boundaries.

## Review Checklist
- Non-replacement framing is explicit
- Core/Companion boundary is preserved
- Evidence/verification/settlement/dispute are not conflated
- Open questions are representation-level
- No transport/execution/payment scope creep

## Supporting Drafts
- `docs/en/00_package_baseline.md`
- `docs/en/10_schema_release_plan.md`
- `docs/en/06_comparison_matrix_short.md`
- `docs/en/11_faq_top5.md`
