# ACP v1 Release Policy (Public Fixed)

This document defines the release criteria fixed at ACP v1 publication.

## Scope

- In scope: `public_bundle` publications, `/conformance` contract, CI gate operation
- Out of scope: internal implementation details of execution frameworks, transport, and payment systems

## v1 Exit Criteria

A v1 release is considered valid only when all of the following are satisfied.

1. `./scripts/public_release_check.sh` succeeds
2. `./scripts/conformance_selftest.sh` succeeds
3. `ACP_CONFORMANCE_MODE=required-external` succeeds with a non-mock production adapter that satisfies the harness contract
4. required-external never becomes fail-open (missing/invalid runner must fail)
5. Public docs preserve Core-15 and non-replacement framing

## Compatibility Rules (v1)

- Maintain backward compatibility for required inputs in `harness_contract_v1.json` (`--contract --profile --request --report`)
- Do not remove required fields from `conformance/templates/report.example.json`
- Additional fields are allowed only if existing consumers are not broken
- Do not change semantics of existing reason codes/status vocabulary

## Breaking Change Prohibition (v1.x)

For the v1 line (`1.x`), the following are treated as breaking changes and are prohibited.

- Rename/remove any Core-15 artifact names
- Change required arguments in the conformance run contract
- Remove required report keys, or apply non-compatible semantic changes to existing keys
- Weaken fail-closed behavior in required-external

## Clarification

- Some campaign or explanatory docs in this bundle retain `Status: Draft` markers.
- Those markers apply to editorial collateral only and do not negate ACP v1 establishment for the protocol line, conformance contract, or this bundle's fixed release criteria.

## Change Management

- Any required incompatible change is handled in v2
- v1-line updates are limited to non-breaking additions, editorial clarity, and operational hardening
- Sync updates with `docs/ja/16_v1_release_execution_plan.md` progress table
