# ACP Conformance Certification

This document defines a practical certification model for external ACP implementations.

## Purpose

Certification tells adopters how far an implementation has been validated against ACP conformance profiles.

## Certification Levels

### L1 - Phase 1 Baseline

L1 means the implementation passes the Phase 1 structural profile.

Evidence required:

- Phase 1 reference or external report
- All valid vectors pass
- All invalid vectors fail as expected
- No report-schema violations

### L2 - Phase 1 + Phase 2

L2 means the implementation passes Phase 1 and Phase 2 profiles.

Evidence required:

- L1 evidence
- Phase 2 report with case-based invariant checks
- Stable handling of causal-order and reservation-related cases

### L3 - Phase 1 + Phase 2 + Phase 3

L3 means the implementation passes all three profiles and the proof-surface binding checks.

Evidence required:

- L2 evidence
- Phase 3 report with companion binding coverage
- Proof-surface checks and reference consistency checks

## Badge Semantics

A badge should communicate exactly which level was earned and when.

Recommended badge labels:

- `ACP Conformance L1`
- `ACP Conformance L2`
- `ACP Conformance L3`

Badge rules:

- A badge must always include a date or renewal marker
- A badge must point to the evidence report or registry entry
- A badge must not imply broader coverage than the certified level

## Renewal

Certification should be renewed when any of the following change:

- The implementation changes materially
- The profile version changes
- The report schema changes
- The conformance contract changes

Recommended renewal window:

- Re-validate on release
- Re-validate at least every 90 days for active public claims

## Revocation

Certification should be revoked or suspended if:

- The implementation no longer passes the certified level
- The evidence report is stale or unverifiable
- A breaking change invalidates the prior certificate
- The implementation misrepresents its level

## Transparency Model

Public certification records should include:

- Implementation name
- Certified level
- Profile versions covered
- Evidence report links
- Issue date and renewal date
- Revocation status, if any

A minimal public registry is enough. The goal is traceability, not bureaucracy.

## CI and Registry Checks

Recommended checks for certification tooling:

- Verify reports against `conformance/report.schema.json`
- Confirm the certificate references the exact profile versions used
- Ensure the claim level matches the evidence scope
- Fail if the evidence is missing, stale, or inconsistent
- Keep registry entries immutable except for renewal or revocation status

## Registry Publication

The conformant implementation registry is published from:

- `docs/registry/implementations.json` (machine-readable source)
- `docs/registry/index.html` (human-readable page)
- `scripts/render_conformance_registry.sh` (renderer)

Operational guide: `docs/en/28_conformant_implementation_registry.md`

## Summary

Certification should help adopters trust a claim quickly without hiding the exact scope of validation.
