# ACP Post-v1 Roadmap — Toward Maturity and Adoption

> **Purpose**: Systematically organize issues, considerations, and specifications needed for ACP to advance from v1 establishment through v1.x hardening, v2 design, and broad adoption.  
> **Audience**: Project owners, contributors, prospective adopters.  
> **Prerequisite**: v1 conditions met per `docs/en/19_v1_declaration.md`. v1 compatibility rules fixed per `docs/en/17_v1_release_policy.md`.

> **Status update (2026-03-27)**: Implemented items include K-1, K-2, K-3, K-4, K-5, C-1, C-2, C-3, C-4, C-5, A-1, A-2, A-3, A-4, B-1, B-2, B-3, B-4, D-1, D-2, D-3, D-4, D-5, E-1, E-2, E-3, E-4, F-1, F-2, F-3, G-1, G-2, G-3, H-1, H-2, H-3, I-1, and I-3.

---

## Current State Summary (v1 Baseline)

| Area | Achieved | Gaps |
|------|----------|------|
| **Schemas** | Core-15 + 9 companion + 2 meta | Vectors cover all 9/9 companion schemas. No `$ref` across schemas. Evolution rules are prose-only |
| **Conformance** | Phase1/2/3 profiles, 38 vectors, 10 invariant cases, parity | Phase1 has no cases yet. External harness certification program is still pending. |
| **CI/CD** | `conformance.yml` (parent repo), 7-step selftest | No bundle-standalone CI. No Dependabot/CodeQL |
| **Docs** | 19 docs (EN/JA) + README set. Baseline / separations / v1 declaration | `15_real_world_impact` has no JA. `16_v1_release_execution_plan` has no EN. No SDK/integration guide |
| **Examples** | `minimal-task` (6 files), `delegated-research` (8 files) | No Phase3 proof/companion end-to-end example. No automated validation walkthrough |
| **Security** | Pinned requirements, SHA256 fingerprint, minimal SBOM, pip-audit | No lock file. No Dependabot/automatic scanning |
| **Governance** | Release policy fixed, breaking-change prohibition | No GOVERNANCE / CONTRIBUTING / CoC / LICENSE file |

---

## Phase Structure

```
v1.x Hardening (now → 6 months)
  ├─ A. Schema quality improvement
  ├─ B. Test pyramid completion
  ├─ C. Developer experience (DX)
  ├─ D. Security and supply-chain hardening
  └─ E. Documentation and translation completeness

v2 Design (6–12 months)
  ├─ F. Schema evolution and machine-readable compatibility
  ├─ G. Interoperability certification program
  └─ H. Multi-runtime reference architecture

Adoption and Ecosystem (12+ months)
  ├─ I. SDKs, libraries, and toolchain
  ├─ J. Real-world templates and case studies
  └─ K. Community and governance
```

---

## A. Schema Quality Improvement (v1.x)

### Issues
- Only 2 of 9 companion schemas have conformance vectors (`canonicalization_binding`, `validator_abi_binding`)
- No `$ref` cross-linking between schemas (logical relationships exist only in profile `schema_map`)
- Many schemas stop at "type + required" without `format`, `pattern`, or `minimum` constraints

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| A-1 | Add valid/invalid vectors for remaining 7 companion schemas | High | 14+ files in `conformance/vectors/phase3/` |
| A-2 | Add `format` / `pattern` / `minLength` constraints to core schemas | Medium | Updated `schemas/core/*.schema.json` |
| A-3 | Explicit schema relationship documentation or `$ref` linking | Medium | `schemas/README.md` + relationship diagram |
| A-4 | Promote companion schemas from "minimal surface" to release quality | Medium | Updated `schemas/companion/` |

---

## B. Test Pyramid Completion (v1.x)

### Issues
- Phase1 has no invariant cases (schema vectors only)
- Phase3 companion structural validation is thin
- No E2E interoperability test framework (by design — transport/runtime is out of scope)

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| B-1 | Add Phase1 invariant cases (agreement→revision→event causal ordering, etc.) | High | `conformance/cases/phase1/` |
| B-2 | Expand Phase3 companion invalid vectors | High | `conformance/vectors/phase3/invalid/` |
| B-3 | Flake detection (CI re-run stability testing) | Medium | Workflow update |
| B-4 | E2E integration test framework design for external runners | Low | Design document |

---

## C. Developer Experience (v1.x)

### Issues
- No `.github/workflows/` when bundle is cloned standalone
- No `package.json` / `pyproject.toml` / `Makefile` — project metadata is README-only
- Examples lack automated validation walkthrough
- No "5-minute quickstart"

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| C-1 | Bundle-standalone `.github/workflows/conformance.yml` | High | `.github/workflows/` |
| C-2 | `Makefile` or `justfile` for one-command operations | Medium | `Makefile` |
| C-3 | Automated example validation script | Medium | `scripts/validate_examples.sh` |
| C-4 | "5-minute quickstart" doc (EN/JA) | High | `docs/*/quickstart.md` |
| C-5 | `pyproject.toml` for standardized project metadata | Low | `pyproject.toml` |

---

## D. Security and Supply-Chain Hardening (v1.x)

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| D-1 | Generate `.lock` file via `pip-compile` and require in CI | High | `requirements-conformance.lock` |
| D-2 | Add Dependabot configuration | High | `.github/dependabot.yml` |
| D-3 | Make `pip-audit` a required CI step | Medium | Workflow update |
| D-4 | Introduce CodeQL / Semgrep static analysis | Low | `.github/workflows/codeql.yml` |
| D-5 | Signed releases (tag signing / cosign) | Low | Release workflow |

---

## E. Documentation and Translation Completeness (v1.x)

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| E-1 | Japanese translation of `15_実務インパクト整理.md` | Medium | `docs/ja/15_実務インパクト整理.md` |
| E-2 | English translation of `16_v1_release_execution_plan.md` | Medium | `docs/en/16_v1_release_execution_plan.md` |
| E-3 | Production harness implementation guide (EN/JA) | High | `docs/*/harness_implementation_guide.md` |
| E-4 | Update `schemas/README.md` maturity statement to reflect current state | Low | `schemas/README.md` |

---

## F. Schema Evolution and Machine-Readable Compatibility (v2)

### Considerations
- Current compatibility rules are prose in `17_v1_release_policy.md` — not machine-verifiable
- When v2 adds/changes fields, how to guarantee v1 report backward-compatibility
- Whether to embed version in JSON Schema `$id` (currently `urn:acp:schemas:core:*_v1`)

### Actions
| # | Task | Deliverable |
|---|------|-------------|
| F-1 | Schema versioning policy | `docs/*/schema_versioning_policy.md` |
| F-2 | Cross-version compatibility tests | Test suite |
| F-3 | Automated schema changelog generation | `scripts/schema_diff.sh` |

---

## G. Interoperability Certification Program (v2)

### Considerations
- `harness_contract_v1.json` and reference implementation exist, but no formal process for certifying external implementations
- Certification levels (e.g., Level 1 = Phase1 pass, Level 2 = Phase2, Level 3 = Phase3 + parity)
- Badge / registry operations

### Actions
| # | Task | Deliverable |
|---|------|-------------|
| G-1 | Define and publish certification levels | `docs/*/conformance_certification.md` |
| G-2 | Packageable certification test suite (`npx` / `pip` runnable) | Published package |
| G-3 | Conformant implementation registry | Website (GitHub Pages etc.) |

---

## H. Multi-Runtime Reference Architecture (v2)

### Considerations
- ACP is an "accountability layer" — transport/runtime intentionally out of scope
- Adopters need "how to integrate" reference architectures
- Need connection patterns for MCP + ACP, A2A + ACP, workflow engines, payment rails

### Actions
| # | Task | Deliverable |
|---|------|-------------|
| H-1 | Integration pattern catalog | `docs/*/integration_patterns.md` |
| H-2 | Reference integration (e.g., Python SDK + FastAPI adapter) | `examples/integrations/` |
| H-3 | Transport-agnostic artifact exchange protocol specification | Design document |

---

## I. SDKs, Libraries, and Toolchain (Adoption)

### Actions
| # | Task | Deliverable |
|---|------|-------------|
| I-1 | Python SDK (schema validation + artifact builder + report parser) | `acp-sdk-python` package |
| I-2 | TypeScript/JavaScript SDK | `acp-sdk-js` package |
| I-3 | CLI tool (`acp validate`, `acp report`, `acp diff`) | `acp-cli` |
| I-4 | VS Code extension (schema completion + validation) | Marketplace |

---

## J. Real-World Templates and Case Studies (Adoption)

### Actions
| # | Task | Deliverable |
|---|------|-------------|
| J-1 | Industry-specific templates (hiring, outsourced production, research, marketing, internal multi-agent) | `examples/templates/` |
| J-2 | Adoption case studies (anonymous OK) | `docs/*/case_studies.md` |
| J-3 | "Integrate ACP in one day" tutorial | `docs/*/tutorial_one_day.md` |

---

## K. Community and Governance (Adoption)

### Actions
| # | Task | Priority | Deliverable |
|---|------|----------|-------------|
| K-1 | Add LICENSE file (MIT / Apache-2.0 etc.) | **Critical** | `LICENSE` |
| K-2 | CONTRIBUTING.md | High | `CONTRIBUTING.md` |
| K-3 | CODE_OF_CONDUCT.md | High | `CODE_OF_CONDUCT.md` |
| K-4 | Issue / PR templates | Medium | `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` |
| K-5 | GOVERNANCE.md (decision process, maintainer responsibilities) | Medium | `GOVERNANCE.md` |
| K-6 | ADR (Architecture Decision Record) directory | Low | `docs/adr/` |

---

## Priority Matrix (Recommended Execution Order)

```
Immediate
  K-1  LICENSE file                          ← Required for public repo
  C-1  Bundle-standalone CI                  ← Forks can't run CI otherwise
  D-1  Lock file generation                  ← Reproducible build foundation
  D-2  Dependabot                            ← Automated vulnerability detection

High (1–2 months)
  A-1  Companion vector expansion
  B-1  Phase1 invariant cases
  C-4  5-minute quickstart
  E-3  Harness implementation guide
  K-2  CONTRIBUTING.md

Medium (3–6 months)
  A-2  Schema constraint strengthening
  B-2  Phase3 companion invalid expansion
  C-2  Makefile
  C-3  Example auto-validation
  D-3  pip-audit CI requirement
  E-1  15_real_world_impact JA translation
  E-2  16_release_execution_plan EN translation

v2 Design (6–12 months)
  F-1–F-3  Schema versioning
  G-1–G-3  Certification program
  H-1–H-3  Integration patterns

Adoption (12+ months)
  I-1–I-4  SDKs / CLI / extensions
  J-1–J-3  Templates / case studies / tutorials
  K-4–K-6  Templates / governance / ADR
```

---

## Maturity Dashboard

Track periodically to visualize project progress.

| Metric | Current | Target (v1.x done) | Target (v2) |
|--------|---------|---------------------|-------------|
| Core schema constraint coverage | 97.8% (133/136 properties constrained) | 80%+ | 95%+ |
| Companion vector coverage | 9/9 (100%) | 9/9 (100%) | 100% + regression |
| Invariant case count | 13 | 25+ | 50+ |
| CI pipelines | Parent-repo + bundle-standalone | Bundle-standalone | + external runner matrix |
| Doc EN/JA symmetry | 10/10 (100%, root docs) | 100% | 100% |
| External harness conformant implementations | 0 (self-authored only) | 1+ | 3+ |
| SDK language count | 1 (Python) | 1 (Python) | 2+ (Python + JS) |
| LICENSE | Set | Set | — |

---

## Immediate Next Actions (Proposal)

1. **I-2** — publish the TypeScript/JavaScript SDK
2. **I-4** — publish the VS Code extension
3. **J-1** — publish industry-specific templates

With these, the project can move from architecture completion toward ecosystem tooling and adoption templates.
