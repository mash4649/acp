# ACP v1 Release Execution Plan (Blocker-Separated)

This plan separates mandatory conditions to establish v1 (release blockers) from post-v1 hardening work.
As a premise, `public_release_check.sh` confirms only the public-package guardrails.
Therefore, the top priority is interoperability release conditions centered on the external harness.

## Scope Classification

### Release blockers (required to establish v1)
1. Fix the external runner contract
2. Standardize failure taxonomy and exit codes
3. Ensure reference/external parity
4. Keep required-external permanently fail-closed
5. Complete representative negative cases for Phase 2/3
6. Fix v1 exit criteria and compatibility rules
7. Prepare runbook for external harness incidents

### Near-term hardening (immediately after v1)
- Expand negative vectors
- Improve evidence-integrity checks
- Dependency locking, SBOM, vulnerability scanning
- Freeze/dispute operation procedures
- One-command verification and self-heal

### Post-v1 growth (adoption and expansion)
- Add real-world templates
- Publish cross-layer reference integrations
- Gather KPI and adoption case studies

## Recommended Execution Order

### 1) Fix Runner contract v1.1
- **Owner layer**: Conformance contract / CLI
- **Goal**: fix the decision surface before implementation and prevent drift in CI/report compatibility
- **DoD**
  - `ACP_HARNESS_RUNNER` interface (`--contract --profile --request --report`) is documented
  - Report shape (required fields, version, compatibility rules) is fixed
  - Exit codes (success / validation failure / environment failure) and stderr policy are fixed
  - `reference_harness.py` and `mock_external_runner.sh` both pass the same contract

### 2) Implement external harness
- **Owner layer**: External runtime adapter
- **Goal**: establish production-minded external mode
- **DoD**
  - `ACP_CONFORMANCE_MODE=required-external` rejects mock runner
  - Real runner can separate success, validation failure, and environment failure
  - External gate runs fail-closed in CI

### 3) Add parity suite
- **Owner layer**: Conformance parity tests
- **Goal**: guarantee verdict consistency before adding volume
- **DoD**
  - For identical fixtures, reference/external `status` matches
  - For identical fixtures, `results[].verdict` matches
  - Minimal reproducible fixtures are saved when diffs occur

### 4) Phase 2/3 hardening (representative cases first)
- **Owner layer**: Profiles / vectors / invariants
- **Goal**: close essential negative-path gaps required for v1 establishment
- **DoD**
  - Representative positive cases + representative negative cases for each invariant are present
  - Reference gate (Phase 2/3) runs stably as required checks
  - CI rerun flakiness is within acceptable bounds

### 5) v1 stabilization docs
- **Owner layer**: Spec governance / release policy
- **Goal**: remove ambiguity in v1 pass/fail criteria
- **DoD**
  - Breaking-change prohibition is explicit in public docs
  - Version compatibility rules are explicit in public docs
  - v1 exit criteria are reflected in public docs

### 6) Security/ops minimum
- **Owner layer**: Security baseline / operations
- **Goal**: satisfy minimum operations/reliability required for v1
- **DoD**
  - Dependency lock policy is defined
  - Minimal SBOM generation + vulnerability-scan pipeline is available
  - Fail-closed operation procedure is documented as a runbook
  - Freeze/dispute minimum procedures are defined

## Priority Principles (Decision Rules)
- **Rule 1**: fix contracts before implementation
- **Rule 2**: prioritize parity over test volume
- **Rule 3**: do not mix v1 blockers and post-v1 work
- **Rule 4**: never allow fail-open (`required-external` is always fail-closed)

## Progress Tracking Template (Operations)

| Item | Owner layer | Status | DoD completion | Blocker |
|---|---|---|---|---|
| Fix Runner contract v1.1 | Conformance contract / CLI | In progress | 85% | Unify public wording for contract version name (v1/v1.1) |
| External harness implementation | External runtime adapter | Done | 100% | - |
| Add parity suite | Conformance parity tests | In progress | 65% | Automate diff-report generation for identical reference/external fixtures |
| Phase 2/3 hardening | Profiles / vectors / invariants | In progress | 80% | Add representative negative cases (coverage expansion) |
| v1 stabilization docs | Spec governance / release policy | Done | 100% | - |
| Security/ops minimum | Security baseline / operations | Done | 100% | - |

## Latest Validation Logs (Pre-v1 confirmation)

- Run date: 2026-03-24
- Commands:
  - `./scripts/public_release_check.sh`
  - `./scripts/conformance_selftest.sh`
  - `./scripts/security_ops_minimum.sh all`
  - `./scripts/security_ops_minimum.sh vuln`
  - `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
- Results:
  - Public guardrail: `public-release-check: ok`
  - Conformance selftest:
    - mock/reference/phase2/phase3: all `ok`
    - external (contract smoke): `ok`
    - required-external negative path (mock rejection): expected failure observed
  - Security/ops minimum:
    - lock fingerprint: generated (`conformance/out/security/requirements-conformance.sha256`)
    - sbom-min: generated (`conformance/out/security/sbom-min.json`)
    - vuln-scan: run with `pip-audit --no-deps --disable-pip`, no known vulnerabilities (`conformance/out/security/vuln-scan.txt`)
  - required-external release gate:
    - runner: `./scripts/acp_harness_runner.sh`
    - status: `pass` / `summary.failed: 0`
    - evidence: `conformance/out/release-gate/report.required-external.json`, `conformance/out/release-gate/summary.required-external.json`

## Final Gate Immediately Before v1 Release

1. Set external runner in `ACP_HARNESS_RUNNER` and pass `required-external` ✅
   - Run: `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/external_release_gate.sh`
   - Artifacts: `conformance/out/release-gate/report.required-external.json`, `summary.required-external.json`
2. Fix `v1 exit criteria` / compatibility rules / breaking-change prohibition in public docs (`docs/ja/17_v1_release_policy.md`, `docs/en/17_v1_release_policy.md`) ✅
3. Implement Security/ops minimum (lock policy, SBOM, vuln scan, runbook) with minimal configuration (runbook: `docs/ja/18_security_ops_minimum_runbook.md` / `docs/en/18_security_ops_minimum_runbook.md`) ✅

## v1 Establishment Declaration (Public)

- Japanese: `docs/ja/19_v1_declaration.md`
- English: `docs/en/19_v1_declaration.md`
