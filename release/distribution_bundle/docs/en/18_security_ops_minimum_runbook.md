# ACP v1 Security/Ops Minimum Runbook

This runbook defines the minimum operations required before a v1 release (lock, SBOM, vulnerability scan, and fail-closed response).

## 1. Preflight

1. `./scripts/public_release_check.sh`
2. `./scripts/conformance_selftest.sh`
3. `./scripts/security_ops_minimum.sh doctor`

Proceed only when all three succeed.

## 2. Lock Policy (Minimum)

- Target file: `requirements-conformance.lock` (fallback: `requirements-conformance.txt` when lock is absent)
- Command: `./scripts/security_ops_minimum.sh lock`
- Output: `conformance/out/security/requirements-conformance.sha256`

Operational rules:

- Regenerate the hash whenever `requirements-conformance.lock` (or fallback `requirements-conformance.txt`) changes
- Confirm hash freshness and diff in release review

## 3. SBOM Generation (Minimum)

- Command: `./scripts/security_ops_minimum.sh sbom`
- Output: `conformance/out/security/sbom-min.json`

Operational rules:

- v1 uses minimum requirements-based SBOM
- Future upgrades may move to CycloneDX/SPDX, but that is not required for v1 gate

## 4. Vulnerability Scan (Minimum)

- Command: `./scripts/security_ops_minimum.sh vuln`
- Output: `conformance/out/security/vuln-scan.txt`
- Execution mode:
  - Preferred: `pip-audit` (`--no-deps --disable-pip`)
  - Fallback: `uvx --from pip-audit pip-audit --no-deps --disable-pip`

Decision:

- If `pip-audit` or `uvx` is available: evaluate findings and remediate High/Critical before release
- If neither is available: keep explicit skip reason in `vuln-scan.txt` and track install TODO

## 5. First Response for fail-closed Incidents

Symptoms:

- `ACP_CONFORMANCE_MODE=required-external` fails
- `ACP_HARNESS_RUNNER` missing, not executable, or contract-incompatible

Response steps:

1. Verify runner path and executable permission
2. Re-run `./scripts/conformance_ci.sh` in `required-external`
3. Capture stderr and verify contract args (`--contract --profile --request --report`)
4. If unresolved, stop release (fail-open is prohibited)

## 6. Minimum freeze/dispute Operation

- Emit a `dispute.opened` event when dispute starts
- Emit `freeze_record_v1` when review freeze-point is required
- Keep verification and settlement decisions separated

## 7. v1 Release Checklist

- [ ] `public_release_check.sh` passed
- [ ] `conformance_selftest.sh` passed
- [ ] `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/external_release_gate.sh` passed
- [ ] lock fingerprint updated
- [ ] sbom-min.json updated
- [ ] vuln-scan.txt reviewed
- [ ] fail-closed/freeze/dispute procedure acknowledged by operators
