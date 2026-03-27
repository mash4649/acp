# ACP (AI Contract Protocol)

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
- Repo-local conformance adapter contract (`/conformance`)
- Phase 1/2/3 profiles with schema vectors and invariant cases
- Repo-local reference harness (`/scripts/reference_harness.py`)
- Split CI gates for mock/reference/external modes
- External harness runner wrapper (`/scripts/conformance.sh`)

Release prerequisite outside this repo:
- Provide an actual external harness path to `ACP_HARNESS_RUNNER` for release/manual fail-closed gates

## Repository Layout
- `/schemas/core` core schema set (Core-15 coverage)
- `/schemas/companion` binding/companion schemas
- `/schemas/meta` reason codes and status registers
- `/schemas/vectors` valid/invalid starter vectors
- `/examples` minimal-task and delegated-research bundles
- `/conformance` thin harness contract/profile/report schema
- `/docs` publishable EN/JA documentation set
- `/public` launch/public communication assets
- `/sdk` SDK implementations (`js`, `python`)
- `/scripts` conformance adapter entrypoint
- `/release/public_bundle` publish-only release bundle assets
- `/vendor` local-only third-party/vendored trees (excluded from ACP distribution repo)
- `/pyproject.toml` repo-level Python project metadata (`[project.optional-dependencies].conformance`)

## GitHub Publishing and Reproducibility
- Upload these as tracked source-of-truth: `/schemas`, `/conformance`, `/docs`, `/examples`, `/scripts`, `/sdk` (excluding generated dependencies), `/public`, `/release/public_bundle`, and root governance/project files.
- Do **not** upload local-only/generated assets listed in `.gitignore` (for example: `.tmp/`, `node_modules/`, Python caches, local venvs, and local-only vendored trees).
- Reproducibility target: a fresh clone can reproduce validation and conformance runs by reinstalling dependencies from lock files (`requirements-conformance.lock`, `sdk/js/acp-sdk-js/package-lock.json`) and running the documented commands.
- Exception: external production harness behavior still requires your own `ACP_HARNESS_RUNNER`; the repo only provides mock/reference baselines.

## Typical `vendor/` Examples
- Embedded third-party source snapshots (for local verification or compatibility checks), for example a pinned upstream tool tree.
- Local patches/forks that are required only for internal testing and are not part of the ACP distribution artifact.
- Generated binaries, package caches, and build outputs should **not** be stored in `vendor/`; keep them in ignored temp/output paths instead.

## Compatibility Position
ACP complements MCP, A2A, workflow engines, and payment systems by providing accountability semantics across them.

## Supporting Public Docs
- `public/README.txt`

## Project Governance
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `GOVERNANCE.md`
- `DISTRIBUTION_SCOPE.md` (what to include/exclude when publishing this repository)

## Launch Surface
- `public/01_message_map.md`
- `public/02_launch_copy_bank.md`
- `public/03_demo_script_90s.md`
- `public/04_share_faq.md`
- `public/07_channel_playbook.md`
- `public/08_demo_script_30s.md`
- `public/09_demo_script_3min.md`
- `public/13_objection_memo.md`
- `./scripts/public_release_check.sh` validates public messaging guardrails (requires **ripgrep** `rg`; on macOS: `brew install ripgrep`)
- `./scripts/prepare_public_bundle.sh` builds a publish-only bundle

## Conformance Adapter Quickstart
- `./scripts/install_conformance_deps.sh` (prefers `requirements-conformance.lock`, falls back to `requirements-conformance.txt` if the lock file is absent)
- `make doctor`
- `make validate-examples`
- `./scripts/conformance.sh doctor`
- `./scripts/conformance.sh prepare`
- `./scripts/conformance.sh run --mock`
- `./scripts/conformance.sh run --reference`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=./scripts/mock_external_runner.sh ./scripts/conformance.sh run`

## Conformance CI Gate
- `ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `.github/workflows/conformance.yml` includes push/PR/manual entrypoints
- `.github/workflows/codeql.yml` runs CodeQL static analysis on push/PR/schedule
- `.github/workflows/release-sign.yml` enforces signed annotated release tags and uploads cosign-signed checksum artifacts
- `./scripts/cross_version_compat.sh` runs cross-version report compatibility checks (v1 fixtures + generated reports)
- `./scripts/schema_diff.sh --old <ref-or-dir> --new <ref-or-dir>` generates schema changelog with compatibility classification
- `./scripts/render_conformance_registry.sh` renders `docs/registry/index.html` from `docs/registry/implementations.json`
- `./scripts/conformance_selftest.sh` runs mock/reference/contract-smoke/negative-path checks
- `make conformance-mock`
- `make conformance-reference`
- `make conformance-phase1`
- `make conformance-phase2`
- `make conformance-phase3`
- `make cross-version-compat`
- `make schema-diff-last`

## Examples Validation
- `./scripts/validate_examples.sh`
- `make validate-examples`

## External Runner Note
- `scripts/mock_external_runner.sh` is a contract test utility only.
- It is not a protocol verifier and not a substitute for your external harness implementation.
- `scripts/reference_harness.py` is a repo-local baseline and not the interoperability authority for external deployments.

## License
- `Apache-2.0` (`./LICENSE`)

## Release Signing
- Create **signed annotated tags** for releases (unsigned or lightweight tags are rejected by `.github/workflows/release-sign.yml`).
- The release-sign workflow creates `acp-<tag>.tar.gz`, generates SHA256, signs the checksum with keyless cosign, and uploads signature/certificate artifacts to the release.

## ACP external harness vs bundled Atrakta (0.14.1)
- `ACP_HARNESS_RUNNER` must be an executable that satisfies the harness CLI contract documented under `/conformance` (for example: `--contract`, `--profile`, `--request`, `--report`).
- The vendored `vendor/atrakta_0.14.1/` tree is a separate Go product used for local runtime verification (`./vendor/atrakta_0.14.1/scripts/dev/verify_loop.sh`). Its `atrakta` CLI is **not** a drop-in `ACP_HARNESS_RUNNER` unless you add a dedicated adapter that implements the harness contract.
- Repository gates: use `--mock` / `--reference` / `mock_external_runner.sh` as documented; production external conformance requires your own harness or adapter binary.
