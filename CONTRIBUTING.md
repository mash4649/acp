# Contributing to ACP

ACP is a public specification and conformance repo. Keep changes small, testable, and aligned with the release policy.

## Setup

1. Clone the repo.
2. Install conformance dependencies with `./scripts/install_conformance_deps.sh`.
3. Confirm the baseline with `./scripts/public_release_check.sh`.
4. Run `bash scripts/conformance.sh run --reference --profile conformance/profiles/phase1.profile.json`.

## What to change

- Prefer focused edits to schemas, vectors, docs, or scripts.
- Keep public messaging consistent with the README and roadmap docs.
- If you add or change examples, validate them with the example validation script once available.

## Checks to run

- `./scripts/public_release_check.sh`
- `bash scripts/conformance.sh run --mock`
- `bash scripts/conformance.sh run --reference`
- `bash release/distribution_bundle/scripts/security_ops_minimum.sh all` when security-related files change

## Pull Requests

- Include a short summary of the behavior or doc change.
- Call out any profile, vector, schema, or governance files you touched.
- Keep PRs scoped to one purpose when possible.
- Add validation notes and mention any skipped checks.

## Review expectations

- Breaking changes to v1 artifacts need explicit rationale and should be rare.
- If you are unsure about compatibility, open an issue before landing the change.
