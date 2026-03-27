Status: Fixed for ACP v1
Type: Reference
Source of truth: `docs/en/00_package_baseline.md`, `/conformance`, and Core-15 schemas under `/schemas`
Last aligned with: ACP v1 public bundle

# ACP

ACP is an accountability layer for delegated AI work.

ACP is not an execution framework, not a transport protocol, and not a payment rail.

## Read this first (non-engineers and engineers)

- **One-page baseline (scope + Core-15 + required separations)**: `docs/en/00_package_baseline.md`
- **v1 establishment + evidence paths**: `docs/en/19_v1_declaration.md`
- **Reproduce all v1 gates and refresh audit evidence**: `./scripts/verify_v1_bundle.sh`

## The three lines to remember (with plain-English intent)

- **Prompt is not contract** (instruction text is not a signed, revision-bound protocol boundary)
- **Claim is not evidence** (assertions are not independently verifiable artifacts)
- **Verification is not settlement** (integrity/acceptance checks are separate from release/hold/refund decisions)

## Conformance Status
Current status: ACP v1 established for this public bundle.

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

Bundled release adapter:
- `scripts/acp_harness_runner.sh` is the non-mock harness adapter used for this bundle's required-external evidence.

## Repository Layout
- `/schemas/core` core artifacts (Core-15)
- `/schemas/companion` binding/companion schemas
- `/schemas/meta` reason/status registries
- `/schemas/vectors` starter vectors and manifest
- `/examples` minimal and delegated workflow bundles
- `/conformance` adapter contract/profile/report schema
- `/scripts` conformance adapter entrypoint
- `/.github/workflows/conformance.yml` conformance gate workflow
- `/docs` public-facing release docs (EN/JA indexes under `docs/en`, `docs/ja`)

## Compatibility Position
ACP complements MCP, A2A, workflow engines, and payment systems by providing accountability semantics across them.

## Public Package Links
- Baseline: `docs/en/00_package_baseline.md`
- Message map: `docs/en/01_message_map.md`
- Launch copy bank: `docs/en/02_launch_copy_bank.md`
- Demo script: `docs/en/03_demo_script_90s.md`
- Share FAQ: `docs/en/04_share_faq.md`
- Channel playbook: `docs/en/07_channel_playbook.md`
- Demo script (30s): `docs/en/08_demo_script_30s.md`
- Demo script (3min): `docs/en/09_demo_script_3min.md`
- Objection memo: `docs/en/13_objection_memo.md`
- Schema release plan: `docs/en/10_schema_release_plan.md`
- Use case: `docs/en/05_anchor_use_case.md`
- Matrix: `docs/en/06_comparison_matrix_short.md`
- FAQ (top 5): `docs/en/11_faq_top5.md`
- Issue packet: `docs/en/14_issue_submission_packet.md`
