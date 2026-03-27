# ACP Schema Versioning Policy

This document defines the compatibility rules for ACP schema evolution.

## Purpose

ACP schemas are versioned so that implementers can determine whether a change is safe to adopt without re-reading the full spec.

## Versioning Model

ACP schema identifiers use a stable artifact name plus a semantic version label.

Recommended machine-readable fields:

- `schema_id`: stable logical identifier
- `schema_version`: published version string
- `compatibility_class`: `compatible`, `forward-compatible`, or `breaking`
- `deprecation_until`: optional removal deadline
- `supersedes`: optional prior schema reference

## Allowed Changes

The following changes are normally compatible within the same major line:

- Add optional fields
- Add new enum values when consumers can ignore unknown values safely
- Tighten documentation without changing validation behavior
- Add non-breaking metadata fields that do not alter required semantics

## Non-Allowed Changes

The following changes are breaking and require a new major version or an explicit migration path:

- Remove required fields
- Change field type or required cardinality
- Change allowed enum values in a way that invalidates existing valid data
- Rename fields without backward-compatible aliases
- Strengthen constraints in a way that rejects previously valid instances

## Deprecation Windows

When a field or schema is being retired:

- Keep the old shape available for at least one published release cycle, or 90 days, whichever is longer
- Mark the successor in docs and machine-readable metadata
- Keep validation and migration guidance available until the deprecation window closes

## CI Checks

Recommended checks for schema changes:

- Validate all schemas with Draft 2020-12
- Run all valid and invalid vectors against the updated schemas
- Confirm that breaking changes are explicitly labeled and version-bumped
- Fail CI if a schema change lacks an associated migration note or deprecation note when required
- Compare schema diffs in review so intentional breakage is visible

## Release Rule

If a change is breaking, do not ship it as a silent patch.

Either:

- Publish a new major version, or
- Provide a documented compatibility shim and migration window

## Summary

The default rule is conservative: preserve compatibility unless the release plan explicitly says otherwise.
