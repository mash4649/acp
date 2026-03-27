# ACP Harness Implementation Guide

This guide describes the minimum production runner contract for `ACP_HARNESS_RUNNER`.

## Purpose

A production harness is the executable that runs ACP conformance outside the repo-local reference harness. It must load the contract, profile, request, and write a schema-valid report.

## Required CLI Arguments

The runner must accept these required arguments:

- `--contract <path>`
- `--profile <path>`
- `--request <path>`
- `--report <path>`

Recommended behavior:

- Exit non-zero if any required argument is missing.
- Treat unknown flags as errors unless you intentionally document extras.
- Keep all paths explicit and file-based. Do not read from stdin or emit the final report to stdout.

## Loading Inputs

Use the provided paths exactly as given.

- Load the contract first to understand the report shape and harness expectations.
- Load the profile next to resolve vectors, schema maps, and cases.
- Load the request last to determine the requested run and output path.
- Resolve relative paths against the repository root or bundle root, not the current working directory, if your harness may be launched from CI.

Practical rule:

- Fail immediately if any input file is missing, unreadable, or invalid JSON.
- Prefer deterministic parsing and stable ordering so repeated runs produce the same report structure.

## Report Obligations

Write a JSON report to `--report` that conforms to `conformance/report.schema.json`.

At minimum the report should include:

- `run_id`
- `profile_id`
- `status`
- `generated_at`
- `summary`
- `results`

Use stable result entries with clear verdicts and messages.

Recommended status model:

- `pass` when all expected checks match.
- `fail` when checks run but mismatch expectations.
- `error` when the runner itself cannot complete the contract.

## Fail-Closed Behavior

ACP release gates must fail closed.

- If the runner cannot load inputs, stop with a non-zero exit code.
- If the report cannot be written, stop with a non-zero exit code.
- If a required dependency or capability is missing, do not fabricate a passing report.
- If the runner sees an unsupported profile or request, report the failure explicitly and exit non-zero.

Do not degrade a hard failure into a silent success.

## Mock vs Production

Use mock mode only for plumbing checks.

- Mock mode should verify script wiring and file paths.
- Production mode should execute the real harness logic and validate the selected profile.
- Do not reuse mock output as production evidence.
- Keep reference and production implementations separate so the repo-local baseline does not become the interoperability authority.

## Minimal Test Checklist

Before using a production runner in release or CI, verify:

- The binary or script is executable.
- `--contract`, `--profile`, `--request`, and `--report` all work end to end.
- The generated report validates against `conformance/report.schema.json`.
- A known-pass profile returns `pass`.
- A known-fail vector or case returns `fail` or `error` as expected.
- The runner exits non-zero when required inputs are missing.

## Integration Notes

- Keep report paths deterministic so CI can archive evidence.
- Log enough detail to debug failures, but do not mix human logs into the JSON report.
- If your production runner wraps another runtime, add a thin adapter that preserves the ACP harness contract.
