Status: Draft
Type: Normative
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# Phase 1 Conformance Vectors

This folder provides starter vectors for Phase 1 schemas.

## Structure
- `valid/`: sample objects expected to pass schema validation
- `invalid/`: sample objects expected to fail schema validation
- `vector-manifest.json`: list of vectors and expected result

## Intended use
Run each vector against the matching schema from `public_assets/schema_templates/phase1/core/`.

## Scope note
These vectors test only structural schema conformance. They do not test full protocol invariants.
