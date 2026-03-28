# ACP (AI Contract Protocol)

ACP is an accountability layer for delegated AI work.

ACP is not an execution framework, not a transport protocol, and not a payment rail.

## Tagline

A concrete accountability protocol for delegated AI work: contract it, verify it, settle it.

## The three lines to remember

- Prompt is not contract.
- Claim is not evidence.
- Verification is not settlement.

## Directory roles

- `docs/` = authoritative documentation
- `assets/` = editable public-facing materials
- `release/` = frozen distribution artifacts

---

## Demo

Use this 30-second flow in your demo GIF/video:

1. Create a minimal task artifact bundle in `examples/minimal-task/`.
2. Run `./scripts/conformance.sh run --reference`.
3. Show the generated verification report in `conformance/out/`.
4. Highlight that ACP separates **execution** from **accountability**.

Suggested visual sequence:

`Task bundle -> ACP conformance run -> verification report -> settlement intent`

---

## TL;DR

ACP solves **unverifiable delegated AI work**.

Without:

- Prompts and logs are mixed together.
- Claims ("done") are not linked to durable evidence.
- Verification and settlement decisions are ambiguous.

With:

- Agreements, revisions, events, evidence, and reports are explicit artifacts.
- Verification is replayable and machine-checkable.
- Settlement intent is emitted as a separate artifact.

Think of it as:

**Git-style traceability for delegated AI accountability.**

---

## Why this exists

- Existing AI tooling focuses on execution speed, not auditable accountability.
- Multi-agent and outsourced workflows need shared evidence, not just chat history.
- Most teams cannot prove "who agreed to what, when, with what evidence" across tools.

---

## What it does

```text
Runtime / Agent Tool A ─┐
Runtime / Agent Tool B ─┼──▶ ACP Artifacts + Rules ───▶ Verifiable Report
Runtime / Agent Tool C ─┘
```

ACP standardizes:

- Contract artifacts (`agreement_v1`, `revision_v1`, `event_v1`)
- Evidence and proof artifacts (`evidence_pack_v1`, `proof_*`)
- Verification and settlement artifacts (`verification_report_v1`, `settlement_intent_v1`)

---

## Quick Start

### Install

```bash
git clone https://github.com/mash4649/acp-project.git
cd acp-project
./scripts/install_conformance_deps.sh
```

### Run

```bash
./scripts/conformance.sh run --reference
```

### Example

```bash
./scripts/conformance.sh run --mock
ls conformance/out
```

---

## Features

- Contract-first artifact model (Core-15 schemas)
- Replayable conformance checks (phase profiles + vectors + cases)
- External harness compatibility via `ACP_HARNESS_RUNNER`
- EN/JA docs and public release bundle assets

---

## Architecture

- `schemas/`: protocol definitions (core/companion/meta/vectors)
- `conformance/`: profiles, test vectors, invariant cases, report schema
- `scripts/`: validation, conformance execution, bundle/export helpers
- `examples/`: minimal and delegated-research reference bundles
- `sdk/`: JS and Python SDK packages
- `assets/`: launch copy, FAQ, demo scripts, and schema templates

---

## Use Cases

- Delegated software delivery with auditable checkpoints
- Multi-agent workflows requiring policy and causality proofs
- External vendor/partner handoff with evidence-backed acceptance

---

## Comparison

| Feature | Existing Tools | ACP |
| ------- | -------------- | --- |
| Prompt history | Yes | Not enough by itself |
| Machine-checkable contract artifacts | Rare | Yes (Core-15) |
| Explicit verification report schema | Usually custom | Yes |
| Settlement intent as first-class artifact | Usually implicit | Yes |
| Fail-closed external runner gate | Usually ad-hoc | Yes |

---

## Ecosystem Position

| Category | Tools | Relation |
| -------- | ----- | -------- |
| Agent transport | MCP / A2A | ACP is complementary |
| Workflow orchestration | Airflow / Temporal / custom runtimes | ACP adds accountability artifacts |
| Payment rail | Stripe / stablecoin rails | ACP provides settlement intent semantics |
| Evidence verification | custom scripts | ACP standardizes report/proof structure |

---

## Roadmap

- Expand production-grade external runner examples
- Strengthen certification suite packaging and registry workflows
- Improve SDK ergonomics and end-to-end developer templates

---

## Documentation

| Topic | Link |
| ----- | ---- |
| English docs index | `docs/en/README.md` |
| Japanese docs index | `docs/ja/README.md` |
| Combined docs index | `docs/README.md` |
| Repository map for first-time contributors | `docs/en/repository_map.md` |
| Public assets index | `assets/README.md` |
| Distribution scope | `DISTRIBUTION_SCOPE.md` |
| Contribution guide | `CONTRIBUTING.md` |
| Governance | `GOVERNANCE.md` |

---

## Contributing

Open an issue first for major changes, then submit a PR with validation results.
See `CONTRIBUTING.md` for rules and review expectations.

---

## License

Apache-2.0 (`LICENSE`)
