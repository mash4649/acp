# Conformance Adapter (Thin Layer)

This directory defines the repo-local contract, profiles, vectors, and invariant cases for ACP conformance execution.

It now includes a repo-local reference harness baseline while preserving the external runner contract.

## Boundary
- In scope: run contract, profile metadata, vector-to-schema mapping, report format.
- Out of scope: execution runtime, transport, payment rails, and full verifier implementation.

## Files
- `harness_contract_v1.json`: normative run contract for external or reference harness integration.
- `report.schema.json`: required report shape written by a harness run.
- `profiles/phase1.profile.json`: Phase 1 vector and schema mapping.
- `profiles/phase2.profile.json`: Phase 2 vector and invariant case mapping.
- `profiles/phase3.profile.json`: Phase 3 vector and invariant case mapping.
- `cases/`: case-based invariant fixtures for Phase 1/2/3.
- `templates/report.example.json`: example report payload.
- `out/`: generated run requests and reports.

## Local Commands
- `./scripts/install_conformance_deps.sh` (prefers `requirements-conformance.lock`, falls back to `requirements-conformance.txt` if needed)
- `make doctor`
- `make validate-examples`
- `./scripts/conformance.sh doctor`
- `./scripts/conformance.sh prepare`
- `./scripts/conformance.sh run --mock`
- `./scripts/conformance.sh run --reference`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=./scripts/mock_external_runner.sh ./scripts/conformance.sh run`
- `./scripts/cross_version_compat.sh` (validate v1 report fixtures against current report schema)
- `./scripts/schema_diff.sh --old <ref-or-dir> --new <ref-or-dir>` (schema changelog + compatibility classification)
- `./scripts/render_conformance_registry.sh` (render `docs/registry/index.html` from registry JSON)

## CI Gate Commands
- `ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `./scripts/conformance_selftest.sh`
- `make conformance-mock`
- `make conformance-reference`
- `make conformance-phase1`
- `make conformance-phase2`
- `make conformance-phase3`

## Example Validation
- `./scripts/validate_examples.sh`
- `make validate-examples`

## Test Utility
- `scripts/mock_external_runner.sh` is for contract-level integration testing.
- `scripts/reference_harness.py` is for repo-local baseline validation.
- Replace mock utilities with your actual external harness runner for real interoperability validation.

## External Runner Contract
External runner must accept these options:
- `--contract <path>`
- `--profile <path>`
- `--request <path>`
- `--report <path>`

The generated report must conform to `conformance/report.schema.json`.
