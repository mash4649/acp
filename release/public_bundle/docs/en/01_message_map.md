Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# ACP Message Map (Core + Surface)

## One-line definition
ACP is an accountability layer for delegated AI work.

## Never-say rules
- Do not present ACP as an execution framework.
- Do not present ACP as a transport protocol.
- Do not present ACP as a payment rail.
- Do not merge evidence, verification, settlement, and dispute semantics.

## Audience map
| Audience | What they care about | Surface headline | Core proof anchor | Call to action |
|---|---|---|---|---|
| Standards researchers | Precise boundary, replayability, interoperability | "Accountability semantics without replacing your stack." | `prompt != contract`, `claim != evidence`, `verification != settlement` + Core-15 | Review `docs/en/06_comparison_matrix_short.md` and `docs/en/10_schema_release_plan.md` |
| Protocol/infra engineers | Deterministic artifacts and verification surface | "Append-only causal history that can be audited and replayed." | `event`, `evidence_pack`, `verification_report`, `settlement_intent`, `freeze_record` | Run `./scripts/conformance_selftest.sh` |
| AI builders and creators | Trustable collaboration and dispute handling | "When delegated AI work fails, accountability does not disappear." | Delegation edge + reservation + freeze/dispute hooks | Review `docs/en/05_anchor_use_case.md` |
| Influencers/media | Clear category and why now | "ACP is the missing accountability layer between prompts and outcomes." | Narrow core + strong invariants + companion profiles | Use `docs/en/02_launch_copy_bank.md` snippets |

## 30-second narrative
Delegated AI work spans many runtimes, tools, and organizations. Logs alone are not enough for shared accountability. ACP defines a narrow, interoperable accountability boundary: agreement and revision control, append-only causal events, evidence-linked verification, explicit settlement intent, and dispute/freeze hooks. ACP complements transport, execution, and payment layers rather than replacing them.
