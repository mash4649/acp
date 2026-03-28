# Repository Map for First-Time Contributors

This page shows where to edit, where to read, and where to expect generated output.

## One-line model

- `docs/` = what people read
- `assets/` = editable public-facing materials
- `release/` = frozen distribution artifacts

## What to edit

| You want to change | Edit this area | Notes |
| --- | --- | --- |
| Canonical guidance, policy, or explanation | `docs/` | This is the source of truth for human-readable documentation. |
| Launch copy, FAQ snippets, demo scripts, schema templates | `assets/` | These are editable source materials for public-facing content. |
| Shipped bundle contents | `release/distribution_bundle/` | Treat this as generated output, not the main edit target. |
| Protocol schemas and vectors | `schemas/` and `conformance/` | These are the authoritative protocol and verification sources. |
| Runnable examples | `examples/` | Use this for quickstarts and sample flows. |

## Recommended reading order

1. `docs/README.md`
2. `docs/en/README.md` or `docs/ja/README.md`
3. `docs/en/repository_map.md` or `docs/ja/リポジトリ全体図.md`
4. `assets/README.md`
5. `release/distribution_bundle/README.md`

## Quick orientation

- If you are writing public documentation, start in `docs/`.
- If you are drafting messaging or demo material, start in `assets/`.
- If you are checking what ships, inspect `release/distribution_bundle/`.
- If you are validating behavior, use `conformance/` and the scripts in `scripts/`.

## Why this exists

The repo has grown to the point where a newcomer can see the same topic reflected in several places.
This page reduces that ambiguity by naming the primary edit target up front.
