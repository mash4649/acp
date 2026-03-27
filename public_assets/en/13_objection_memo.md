Status: Draft
Type: Discussion
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# ACP Objection Memo

## O1. "Is this just another agent protocol?"
Response:
No. ACP is scoped to accountability semantics for delegated AI work. Transport and execution are explicitly out of scope.

Evidence to show:
- `public_assets/en/06_comparison_matrix_short.txt`
- `README.md` "What ACP Is Not"

## O2. "Why not just use workflow logs?"
Response:
Logs are execution-local and often stack-specific. ACP defines interoperable artifacts for contract, evidence, verification, settlement intent, and dispute/freeze across stacks.

Evidence to show:
- `public_assets/en/05_anchor_use_case.txt`
- `schemas/core/*`

## O3. "Why split verification and settlement?"
Response:
Separation prevents accidental release semantics and supports dispute governance. A verification outcome is not equivalent to settlement finality.

Evidence to show:
- `public_assets/en/11_faq_top5.md`
- `schemas/core/verification_report_v1.schema.json`
- `schemas/core/settlement_intent_v1.schema.json`

## O4. "Can ACP replace MCP/A2A?"
Response:
No. ACP complements communication and execution layers. It does not replace them.

Evidence to show:
- `public_assets/en/01_message_map.md`
- `public_assets/en/06_comparison_matrix_short.txt`

## O5. "Is Core too large at 15 artifacts?"
Response:
Core-15 is the invariant boundary. Publication can be phased, but core semantics should not be redefined as a smaller ontology.

Evidence to show:
- `public_assets/en/10_schema_release_plan.md`
- `README.md` "Core Artifacts"
