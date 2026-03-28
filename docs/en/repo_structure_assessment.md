# Repository Structure Assessment

This document checks whether the current `acp/` layout is easy to understand for a first-time user and whether the directory boundaries match the work each directory is supposed to own.

## Short answer

Keep the current layout. The structure is already close to the right separation of concerns, but a few boundaries need to be made explicit in the next task.

The main rule is simple:

- `docs/` is the authoritative documentation layer
- `assets/` is the editable source material for public-facing copy and schema templates
- `release/distribution_bundle/` is the frozen shipping artifact
- `examples/`, `schemas/`, `conformance/`, `scripts/`, and `sdk/` remain the editable source areas

## Responsibility table

| Path | Purpose | Primary editor | Primary users |
| --- | --- | --- | --- |
| `acp/docs/` | Canonical public documentation | Docs maintainers | contributors, adopters, reviewers |
| `acp/schemas/` | Source schemas and schema docs | Protocol maintainers | validators, SDK authors, test authors |
| `acp/conformance/` | Profiles, vectors, cases, outputs | Protocol maintainers and CI | harness authors, release checks |
| `acp/examples/` | Runnable examples and templates | Example maintainers | users trying ACP locally |
| `acp/scripts/` | Validation, release, and helper scripts | Maintainers | CI, release automation, adopters |
| `acp/sdk/` | SDK implementations | SDK owners | application developers |
| `acp/assets/` | Launch copy, FAQ, demo scripts, schema templates | Docs / release content owners | public docs editors, launch prep, release packaging |
| `acp/release/distribution_bundle/` | Frozen public bundle for release | Release automation | bundle consumers, public bundle reviewers |

## Boundary check: `assets/` vs `release/distribution_bundle/`

### `assets/`

Use this as the editable source for launch-facing material:

- copy bank
- demo scripts
- FAQ snippets
- objection handling notes
- schema template inputs

This directory should stay editable. It is where content is prepared before it is published.

### `release/distribution_bundle/`

Use this as the shipping artifact:

- frozen docs
- bundled schemas and examples
- release scripts
- conformance outputs
- reproducible bundle state

This directory should be treated as output, not as the source of truth for editing.

### Verdict

The separation is valid and should stay in place.

Do not merge the two directories. The lifecycle is different:

- `assets/` changes frequently as source content
- `release/distribution_bundle/` changes only when the bundle is regenerated

## Comparison of options

| Option | Description | Risk | Decision |
| --- | --- | --- | --- |
| Minimal-change | Keep the current layout, clarify responsibilities, add explicit links and owner notes | Low | **Chosen** |
| Full reorganization | Rename and move multiple top-level directories into a new layout | High | Rejected for now |

## Why minimal-change is the right call

- The current tree already separates source, docs, examples, scripts, and release artifacts.
- Most confusion comes from responsibility boundaries, not from path names alone.
- A large move would create unnecessary reference churn before the responsibilities are written down.

## Impact checklist

This is the checklist for the next task.

- update directory responsibility docs
- review internal links that point at `assets/`
- review internal links that point at `release/distribution_bundle/`
- verify docs indexes still point to canonical docs
- confirm release bundle paths remain read-only expectations
- confirm example paths are still used for user-facing quickstarts

## What S-2 should implement next

S-2 should turn this diagnosis into a concise directory-responsibility specification:

- source vs generated
- editable vs frozen
- source of truth vs distribution artifact
- who edits what

That task should be able to update references without moving the directory tree.
