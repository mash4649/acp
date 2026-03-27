# External Runner E2E Integration Test Framework

This note defines the smallest useful test framework for validating an ACP external runner end to end.
It is a design document, not a runner contract change.

## Why this exists

ACP already has a conformance contract, a reference harness, and a bundled adapter path.
What is still missing is a repeatable way to test an external runner as a black box while keeping evidence handling explicit.

The framework should answer four questions:

1. Did the runner accept the expected contract inputs?
2. Did it produce the expected report and artifacts?
3. Did the run stay stable across a repeat execution?
4. Can the resulting evidence be compared without relying on transient fields?

## Scope

In scope:

- runner invocation from a fixed fixture
- repeat execution of the same fixture
- normalized comparison of reports and evidence
- evidence capture for later audit

Out of scope:

- changes to the external runner contract itself
- changes to ACP schemas
- transport-specific integrations
- CI matrix expansion beyond the minimal framework

## Minimal framework shape

The framework has three layers:

### 1. Fixture

A fixture is a self-contained test case containing:

- input profile
- request payload or request manifest
- expected artifact set
- expected evidence constraints

The fixture must be deterministic. If a fixture needs time, paths, or generated IDs, those values must be normalized before comparison.

### 2. Runner contract

The framework should invoke the external runner through the same contract used by conformance gates.
The contract boundary is preserved:

- the framework does not reach into runner internals
- the framework only observes the runner input and output files
- the runner is free to implement its own runtime, transport, or adapter layer

### 3. Evidence comparison

The framework compares evidence in two passes:

- structural validation: report shape, required fields, and artifact presence
- normalized stability check: compare a sanitized version of the outputs across reruns

Fields such as run IDs, generated timestamps, and other volatile metadata should be removed before diffing.

## Suggested execution flow

1. Load one fixture.
2. Run the external runner once and collect outputs.
3. Validate the outputs against the ACP schemas and the local report shape.
4. Normalize volatile fields.
5. Run the same fixture a second time.
6. Normalize the second output.
7. Compare the two normalized outputs.
8. Record pass/fail and keep the raw evidence bundle.

## Evidence bundle contents

The evidence bundle should include:

- the fixture used
- the raw report from each execution
- normalized comparison output
- pass/fail summary
- runner identifier and execution timestamp

The bundle should be append-only and suitable for audit review.

## Stability signals

The framework should treat these as potential flake indicators:

- normalized report differences across identical reruns
- missing artifacts on the second run
- unstable ordering in append-only fields
- report shape changes without a version bump

The framework should not fail on expected volatility alone. It should fail when volatility leaks into stable fields.

## Practical adoption path

Start with a single fixture and a single runner target.
Only after the basic framework is stable should it expand to:

- multiple fixtures
- multiple runner implementations
- cross-version comparisons
- long-run regression tracking

## Relation to other docs

- `25_integration_patterns.md` explains how ACP fits around adjacent systems.
- `29_transport_agnostic_artifact_exchange_protocol.md` defines the transport-agnostic artifact exchange shape.
- This document defines the test harness that can validate an external runner against that boundary.

