# Companion Schemas

This directory contains companion and binding schemas.

## Scope in this snapshot
- Canonicalization binding
- Signature envelope binding
- Trust registry binding
- Validator ABI binding
- Policy runtime ABI binding
- Dispute process binding
- Transparency binding
- Oracle market binding (conditional)
- Streaming settlement binding (conditional)

## Notes
- These schemas are binding surfaces, not replacements for Core semantics.
- Each schema enforces release-grade baseline constraints:
  - explicit `required` fields
  - `additionalProperties: false`
  - non-empty string guards (`minLength`)
  - version/date/hash/id pattern guards (`pattern` / `format`)
- Rail-specific logic and market mechanics remain outside Core schemas.
