# Certification Test Suite Packaging

This document describes `scripts/export_certification_suite.sh`, which exports a distributable certification suite baseline for external conformance execution.

## Level Mapping

| Level | Phase profile | Profile ID |
| --- | --- | --- |
| `level1` | `conformance/profiles/phase1.profile.json` | `phase1-accountability-minimum` |
| `level2` | `conformance/profiles/phase2.profile.json` | `phase2-delegation-policy-safety` |
| `level3` | `conformance/profiles/phase3.profile.json` | `phase3-proof-surface-bindings` |

The selected level determines the profile that is highlighted in the package README and manifest.

## Usage

```bash
./scripts/export_certification_suite.sh --level level1
./scripts/export_certification_suite.sh --level level2 --out-root .tmp/certification-suite
./scripts/export_certification_suite.sh --level level3 --out-root /tmp/acp-suite-export
```

The script validates the requested level, builds a package directory, and also writes a gzip tarball next to it.

## Output

For `--level level1`, the default output names are:

- `ACP-certification-suite-level1/`
- `ACP-certification-suite-level1.tar.gz`

The exported directory includes:

- `README.md` with package-specific usage notes
- `manifest.json` with machine-readable inventory metadata
- `conformance/` with the contract, profiles, vectors, cases, templates, and local metadata
- `schemas/` with the schema catalog and vector fixtures
- `scripts/` with the conformance runner and helper scripts
- `LICENSE`
- `requirements-conformance.lock`
- `requirements-conformance.txt` when present in the source tree

`conformance/out/` is intentionally excluded from the export. It is generated when the package is used to run conformance.

## Evidence Expectations

A certification-suite export is considered practical only if it supports the following evidence trail:

- `bash -n` succeeds on the export script
- `./scripts/conformance.sh doctor --profile <selected profile>` returns `doctor: ok`
- `./scripts/conformance.sh run --reference --profile <selected profile>` or an external harness run produces a report that validates against `conformance/report.schema.json`
- The resulting report shows the expected `profile_id`, `status`, and `failed = 0` for a passing run
- The run request, report, and stdout/stderr log are retained as evidence

## Package Notes

The generated `manifest.json` records:

- the selected level and phase
- the selected profile path and profile ID
- inventory counts for schemas, vectors, and cases
- the package paths included in the export

The practical baseline is intentionally broad enough to run conformance outside the source repository without additional manual assembly.
