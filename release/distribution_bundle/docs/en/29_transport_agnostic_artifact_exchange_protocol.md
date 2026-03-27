# Transport-Agnostic Artifact Exchange Protocol

This document defines a transport-agnostic protocol for exchanging ACP artifacts across systems.

## Scope

This protocol defines:

- package structure for artifact exchange
- manifest fields and verification requirements
- integrity and replay expectations
- status and acknowledgement semantics

This protocol does not define:

- runtime orchestration
- message transport bindings
- payment or settlement rail behavior

## Design Goals

- Keep artifact exchange deterministic and replayable.
- Keep transport and runtime choices out of the protocol core.
- Preserve append-only accountability history.
- Enable independent verification with minimal assumptions.

## Exchange Unit

The exchange unit is an **Artifact Exchange Package (AEP)**.

An AEP is a directory or archive containing:

- `manifest.json`
- `artifacts/` (ACP artifacts as JSON)
- `checksums.sha256`
- optional `signature/` directory

## Required Package Layout

```text
<package>/
  manifest.json
  checksums.sha256
  artifacts/
    agreement.json
    revision.json
    event.activation.json
    evidence_pack.json
  signature/                    # optional
    checksums.sha256.sig
    checksums.sha256.pem
```

## Manifest Schema (Protocol v1)

Required top-level fields:

- `protocol_version`: string (`"aep-v1"`)
- `exchange_id`: stable unique ID for this package
- `generated_at`: RFC3339 timestamp
- `producer`: producer identifier
- `artifacts`: array of artifact descriptors

Each artifact descriptor must include:

- `path`: relative path under `artifacts/`
- `artifact_type`: ACP artifact type (for example `agreement_v1`)
- `artifact_id`: artifact identity field value
- `sha256`: checksum for the file bytes

Optional fields:

- `previous_exchange_id`: links append-only exchange history
- `profile_id`: conformance profile context
- `notes`: producer note array

## Validation Rules

A receiver must:

1. Verify `manifest.json` is present and parseable JSON.
2. Verify required manifest fields are present.
3. Verify every listed artifact file exists.
4. Verify file checksums against both `manifest.json` and `checksums.sha256`.
5. Reject package if any checksum mismatch exists.
6. Validate each artifact against its ACP schema before use.

If optional signature files are present, verify signature before accepting package as trusted evidence.

## Replay and Ordering

- Packages are append-only; do not mutate prior package contents.
- If `previous_exchange_id` is present, it must reference an already-known package.
- Causal ordering must be reconstructed from ACP artifacts (`event_v1`, `revision_v1`, edges), not transport timestamps.

## Status and Acknowledgement

Receivers should emit one of these statuses per package:

- `accepted`: package passed integrity and schema checks
- `rejected`: package failed integrity/schema checks
- `incomplete`: package is structurally valid but insufficient for requested verification

Recommended acknowledgement payload:

- `exchange_id`
- `status`
- `processed_at`
- `reasons` (array of stable reason strings)

## Failure Semantics

- On integrity failure: reject and keep original bytes for audit.
- On schema failure: reject and include artifact path + validation reason.
- On partial availability: mark `incomplete` instead of fabricating acceptance.

## Compatibility

- Future protocol revisions must use a new `protocol_version` value.
- Additive fields in `manifest.json` are forward-compatible if receivers ignore unknown keys.
- Removing required fields or changing required semantics is breaking.

## Minimal Interop Checklist

- Producer emits AEP with deterministic checksums.
- Receiver validates checksums and schemas fail-closed.
- Receiver can replay at least one agreement→revision→event chain from exchanged artifacts.
- Exchange IDs are unique and traceable in logs.

## Summary

AEP v1 gives ACP implementations a transport-neutral way to exchange verifiable artifact packages while preserving accountability boundaries and replayability.
