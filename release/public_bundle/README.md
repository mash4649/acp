# ACP (AI Contract Protocol)

ACP is an accountability layer for delegated AI work.

ACP is not an execution framework, not a transport protocol, and not a payment rail.

## Start here (for both engineers and non-engineers)

- **One-page baseline (scope + Core-15 + required separations)**: `docs/en/00_package_baseline.md`
- **v1 establishment + evidence paths**: `docs/en/19_v1_declaration.md`
- **Reproduce all v1 gates and refresh audit evidence**: `./scripts/verify_v1_bundle.sh`

## The three lines to remember

- Prompt is not contract.
- Claim is not evidence.
- Verification is not settlement.

## What ACP does (short)

ACP defines a narrow, replay-auditable interoperability boundary for **agreement/revision**, **append-only causal events**, **evidence-bound verification**, **explicit settlement intent**, and **dispute/freeze semantics** — without replacing your runtime, transport, or payment systems.

## Conformance Status
Current status: ACP v1 established for this public bundle.

Available now:
- Repo-local conformance adapter contract (`/conformance`)
- Phase 1/2/3 profiles with schema vectors and invariant cases
- Repo-local reference harness (`/scripts/reference_harness.py`)
- Split CI gates for mock/reference/external modes
- External harness runner wrapper (`/scripts/conformance.sh`)

Bundled release adapter:
- `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh`

## Repository Layout
- `/schemas/core` core schema set (Core-15 coverage)
- `/schemas/companion` binding/companion schemas
- `/schemas/meta` reason codes and status registers
- `/schemas/vectors` valid/invalid starter vectors
- `/examples` minimal-task and delegated-research bundles
- `/conformance` thin harness contract/profile/report schema
- `/scripts` conformance adapter entrypoint
- `/pyproject.toml` repo-level Python project metadata (`[project.optional-dependencies].conformance`)

## Compatibility Position
ACP complements MCP, A2A, workflow engines, and payment systems by providing accountability semantics across them.

## Supporting Public Docs
- `docs/README.md` (EN/JA combined index)
- `docs/en/README.md` (English index)
- `docs/ja/README.md` (Japanese index)

## Launch Surface
- `docs/en/01_message_map.md`
- `docs/en/02_launch_copy_bank.md`
- `docs/en/03_demo_script_90s.md`
- `docs/en/04_share_faq.md`
- `docs/en/07_channel_playbook.md`
- `docs/en/08_demo_script_30s.md`
- `docs/en/09_demo_script_3min.md`
- `docs/en/13_objection_memo.md`
- `./scripts/public_release_check.sh` validates public messaging guardrails (requires **ripgrep** `rg`; on macOS: `brew install ripgrep`)
- `./scripts/verify_v1_bundle.sh` runs install + all v1 gates and refreshes `conformance/out/` audit evidence (see `docs/en/19_v1_declaration.md`)
- If you maintain a **separate full ACP checkout**, its `project/scripts/prepare_public_bundle.sh` copies `release/public_bundle/` to a publish directory (that script is not shipped in this repository)

## Conformance Adapter Quickstart
- `./scripts/install_conformance_deps.sh` (installs Python deps into a versioned `.tmp/conformance-deps-pyXY` directory)
- `./scripts/verify_v1_bundle.sh` (installs deps, runs public check + selftest + required-external gate + security minimum; refreshes `conformance/out/v1-evidence.*`)
- `ACP_AUTO_INSTALL_CONFORMANCE_DEPS=1 ./scripts/conformance_selftest.sh` (optional: install then selftest in one step)
- `./scripts/conformance.sh doctor`
- `./scripts/conformance.sh prepare`
- `./scripts/conformance.sh run --mock`
- `./scripts/conformance.sh run --reference`
- `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=./scripts/mock_external_runner.sh ./scripts/conformance.sh run`

## Conformance CI Gate
- `ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `.github/workflows/conformance.yml` is bundle-standalone CI for public-release guardrail plus mock/reference conformance checks.
- `.github/workflows/codeql.yml` runs CodeQL static analysis on push/PR/schedule.
- `.github/workflows/release-sign.yml` enforces signed annotated release tags and uploads cosign-signed checksum artifacts.
- `./scripts/cross_version_compat.sh` runs cross-version report compatibility checks (v1 fixtures + generated reports).
- `./scripts/schema_diff.sh --old <ref-or-dir> --new <ref-or-dir>` generates schema changelog with compatibility classification.
- `./scripts/render_conformance_registry.sh` renders `docs/registry/index.html` from `docs/registry/implementations.json`.
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/external_release_gate.sh` (required-external release evidence bundle)
- `.github/workflows/conformance.yml` includes push/PR/manual entrypoints
- `./scripts/conformance_selftest.sh` runs mock/reference/contract-smoke/negative-path checks plus `[7/7]` parity (reference vs bundled runner; expects zero diff)
- `./scripts/conformance_parity.sh` compares reference and `ACP_HARNESS_RUNNER` reports for the same profile and writes `conformance/out/parity/parity-report.<profile>.json` (non-zero exit on mismatch)
- `ACP_HARNESS_RUNNER=... ACP_HARNESS_RUNNER_2=... ./scripts/production_runner_compare.sh` compares two production runners’ required-external reports (wrapper for `conformance_parity.sh` `runner-runner` mode)

## Security/Ops Minimum (v1)
- `./scripts/security_ops_minimum.sh doctor`
- `./scripts/security_ops_minimum.sh all`
- Output: `conformance/out/security/`
- Runbook: `docs/en/18_security_ops_minimum_runbook.md`

## External Runner Note
- `scripts/mock_external_runner.sh` is a contract test utility only.
- It is not a protocol verifier and not a substitute for a full external harness implementation.
- `scripts/reference_harness.py` is a repo-local baseline used by development and by the bundled adapter below.
- `scripts/acp_harness_runner.sh` is the **bundled non-mock harness adapter** for this public bundle. It satisfies the harness CLI contract and is the runner used for `required-external` evidence in `docs/en/19_v1_declaration.md` and `conformance/out/`.

## ACP external harness vs agent runtimes
- Any `ACP_HARNESS_RUNNER` value must be an executable that satisfies the harness CLI contract under `/conformance` (for example: `--contract`, `--profile`, `--request`, `--report`).
- agent runtimes are separate products. Their CLIs are **not** drop-in `ACP_HARNESS_RUNNER` values unless you ship an adapter that implements the harness contract (this bundle ships `acp_harness_runner.sh` as its contract-compliant adapter).

## Release Signing
- Create **signed annotated tags** for releases (unsigned or lightweight tags are rejected by `.github/workflows/release-sign.yml`).
- The release-sign workflow creates `acp-<tag>.tar.gz`, generates SHA256, signs the checksum with keyless cosign, and uploads signature/certificate artifacts to the release.
