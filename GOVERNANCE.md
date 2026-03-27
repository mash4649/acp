# ACP Governance

## Purpose

This document describes how ACP is maintained, how decisions are made, and how release policy is enforced.

## Maintainer Responsibilities

Maintainers are responsible for:

- Protecting the v1 compatibility boundary
- Reviewing schema, conformance, doc, and security changes for consistency
- Keeping public docs and release artifacts aligned
- Ensuring required checks pass before release or publication
- Handling conduct reports and escalation paths

## Decision Process

- Routine changes may be merged by a maintainer after review and passing checks.
- Compatibility-sensitive changes require explicit maintainer acknowledgement.
- When there is disagreement, the default is to preserve the current v1 behavior until a clear resolution is documented.
- If a change affects release policy, it must be reflected in the release policy docs before or with the code change.

## Release Policy Tie-In

ACP v1 release policy is the source of truth for compatibility and breaking-change handling.

- v1 artifacts should remain stable unless the release policy is updated.
- New vectors, docs, and checks should strengthen the current contract rather than redefine it.
- Release candidates should pass the public release check, conformance checks, and security minimum checks before publication.

## Change Types

- Docs-only changes may be merged quickly if they are accurate and scoped.
- Schema or vector changes should include matching conformance updates.
- Security-sensitive changes should include lock, audit, or runbook updates where applicable.

## Maintainer Rotation

Maintainers may be added or removed by explicit maintainer agreement documented in the repo history or a future governance record.

## Amendments

This file may be updated when the project grows new release stages, formal membership rules, or a broader maintainer set.
