Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# ACP Channel Playbook

## Objective
Keep category boundaries strict while making ACP easy to share across research and creator channels.

## Channel-by-channel
| Channel | Audience | Primary message | Asset to use | CTA |
|---|---|---|---|---|
| GitHub Release | Engineers and maintainers | "Public draft of an accountability layer, not a runtime replacement." | `README.md`, `public_assets/en/10_schema_release_plan.md` | Run `./scripts/public_release_check.sh` and `./scripts/conformance_selftest.sh` |
| X / LinkedIn | Researchers and creators | "Delegated AI needs replayable accountability." | `public_assets/en/02_launch_copy_bank.md` short post/thread | Link to repo README and use-case doc |
| Blog / Note | Standards and protocol readers | "Narrow core + strong invariants + companion profiles." | `public_assets/en/01_message_map.md`, `public_assets/en/06_comparison_matrix_short.txt` | Invite issue comments via `public_assets/en/14_issue_submission_packet.md` |
| Talk / Demo | Influencers and community leads | "Show artifacts and separation principles in 90 seconds." | `public_assets/en/03_demo_script_90s.md` | Direct to examples and schemas |
| Deep-dive session | Implementers | "How to integrate ACP with existing stack." | `public_assets/en/05_anchor_use_case.txt`, `schemas/*`, `conformance/*` | Start with Phase 1 profile |

## Messaging split
- Surface line: accountability for delegated AI work.
- Core line: explicit separations and append-only + replayable invariants.

## Mandatory guardrails for every channel
- Say what ACP is not in the first minute.
- Include at least one separation statement:
  - prompt is not contract
  - claim is not evidence
  - verification is not settlement
- Do not compare as a winner-takes-all replacement.
