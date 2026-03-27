# ACP Lite

ACP Lite is the smallest useful entry point for a small team that wants accountability without enterprise overhead.

It keeps the same boundary:

- execution is still the command that runs the work
- accountability is still the report that proves what happened

It removes the extra weight:

- no governance package on day 1
- no multi-harness recipe set
- no broad adoption program

## Who this is for

- a small internal team
- a single repository owner
- a solo maintainer who needs evidence
- a lightweight pilot with a clear scope

## Minimum flow

### 1) Prepare one minimal task

Use the smallest bundle that still shows the boundary clearly:

- `examples/minimal-task/`
- one repo
- one scope
- one owner

### 2) Run one command

From the repository root, run:

```bash
./scripts/conformance.sh run --reference
```

### 3) Confirm one report

Check the output directory:

```bash
ls conformance/out
```

Success means:

- the command exits with status `0`
- a report file exists in `conformance/out/`
- the report shows a pass result

## What ACP Lite keeps

| Kept | Why |
| --- | --- |
| Execution vs accountability split | The core ACP value |
| `conformance.sh` reference run | One repeatable proof point |
| `conformance/out/` report | Evidence that can be reviewed later |
| Minimal task scope | Fast adoption for small teams |

## What ACP Lite leaves out

| Omitted | Why |
| --- | --- |
| Full governance package | Too heavy for first use |
| Multi-harness catalog | Not needed for the first win |
| Enterprise rollout program | Better as a later step |
| Broad use-case library | Start with one successful path |

## Enterprise vs Lite

| Topic | Enterprise ACP | ACP Lite |
| --- | --- | --- |
| Audience | Org-wide rollout | Small team or single repo |
| Setup | Complete docs and governance | Minimal docs and minimal ceremony |
| Proof | Multi-use-case adoption path | One command, one report |
| Goal | Standardize accountability across teams | Prove value quickly |

## Failure notes

- If the command fails before a report appears, install the missing conformance dependencies first.
- If the report exists but is not passing, inspect `status`, `summary.failed`, and `results`.
- If the task feels too big, shrink it until it fits one owner and one output.

## Bottom line

ACP Lite is the fast path for proving that execution and accountability can stay separate in a small, real project.
