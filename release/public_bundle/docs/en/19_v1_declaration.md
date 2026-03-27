# ACP v1 Declaration

This declaration records that ACP v1 release conditions are satisfied for this `public_bundle`.

## Declaration

ACP v1 is considered established because all required conditions are satisfied.

1. Public guardrail checks pass
2. Conformance selftest passes
3. required-external gate passes with the bundled non-mock ACP harness adapter
4. Security/Ops minimum (lock, SBOM, vuln-scan, runbook) is implemented
5. v1 release policy (exit criteria / compatibility / breaking change prohibition) is publicly fixed

## Execution Evidence

- Public guardrail:
  - `./scripts/public_release_check.sh` -> `ok`
  - Evidence:
    - `conformance/out/v1-evidence.public_release_check.txt`
- Conformance selftest:
  - `./scripts/conformance_selftest.sh` -> `ok`
  - Evidence:
    - `conformance/out/v1-evidence.conformance_selftest.txt`
- required-external:
  - Command: `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
  - Evidence:
    - `conformance/out/v1-evidence.required_external.txt`
    - `conformance/out/release-gate/report.required-external.json`
    - `conformance/out/release-gate/summary.required-external.json`
    - `conformance/out/release-gate/env.required-external.txt`
- security/ops minimum:
  - `./scripts/security_ops_minimum.sh all` -> `ok`
  - `./scripts/security_ops_minimum.sh vuln` -> `no known vulnerabilities (pip-audit)`
  - Evidence:
    - `conformance/out/v1-evidence.security_ops_minimum.txt`

## Reproducible verification

Run `./scripts/verify_v1_bundle.sh` from the bundle root (needs `pip` network access once). It reinstalls conformance deps, reruns every gate above, and overwrites the `conformance/out/v1-evidence.*` files plus `conformance/out/release-gate/` and `conformance/out/security/`.

## Compatibility Commitments (v1 line)

- Do not rename/remove Core-15 artifact names in v1 line
- Keep backward compatibility for required conformance run contract args
- Do not remove required report keys or apply non-compatible semantic changes
- Do not weaken fail-closed behavior in required-external

## Scope Clarification

- Some campaign or explanatory docs in this bundle retain `Status: Draft` markers.
- Those markers apply to editorial collateral only and do not invalidate ACP v1 establishment for the protocol line, conformance contract, or release criteria fixed here.

## Post-v1 Work (Implemented)

1. **Parity diff (reference vs external report)**  
   - Run `./scripts/conformance_parity.sh` (default `ACP_PARITY_MODE=reference-external`).  
   - Output: `conformance/out/parity/parity-report.<profile>.json`; non-zero exit on mismatch.  
   - Compare existing reports only: `ACP_PARITY_MODE=compare-only` with `ACP_PARITY_LEFT_REPORT` and `ACP_PARITY_RIGHT_REPORT`.  
   - Selftest step `[7/7]` asserts zero diff against the bundled runner.

2. **Phase 2/3 negative vectors**  
   - Additional invalid vectors (declared `artifact_type` inconsistent with payload shape, wrong numeric type, `additionalProperties` violations), synced in manifests and profiles.

3. **Multiple production runners**  
   - Run `./scripts/production_runner_compare.sh` with `ACP_HARNESS_RUNNER` and `ACP_HARNESS_RUNNER_2` (wrapper for `conformance_parity.sh` `runner-runner` mode).
