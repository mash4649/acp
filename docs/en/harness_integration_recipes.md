# Harness Integration Recipes

This page shows how to connect ACP with common harnesses without collapsing ACP into the harness itself.

Use the same pattern in every recipe:

| Topic | What to record |
| --- | --- |
| Role split | Which tool executes work and which tool records accountability |
| Execution point | The command or action that actually runs the workflow |
| Evidence | Where reports, artifacts, and review notes are stored |

## 1) Claude Code

### Role split
- Claude Code drives the interactive coding session.
- ACP records the agreement boundary, revisions, evidence, and verification report.

### Execution point
- Run the task in Claude Code.
- After the session, run the ACP conformance command from the repository root.

```bash
./scripts/conformance.sh run --reference
```

### Evidence
- `examples/minimal-task/` for the smallest reproducible bundle
- `conformance/out/` for the generated verification report
- `docs/en/case_studies.md` or your own case log for the human explanation

### Recipe
1. Start with one scoped task.
2. Keep the prompt in Claude Code and the contract in ACP separate.
3. Export the outcome into `agreement_v1`, `revision_v1`, and `verification_report_v1`.

## 2) Codex

### Role split
- Codex executes the implementation loop.
- ACP records what was delegated, what changed, and what was verified.

### Execution point
- Use Codex to edit the repository and run the smallest useful validation.
- End the loop with the ACP reference run.

```bash
./scripts/conformance.sh run --reference
```

### Evidence
- Keep the command output in the terminal history.
- Save the verification report under `conformance/out/`.
- Add a short note about the boundary that was accepted or revised.

### Recipe
1. Let Codex make one bounded change.
2. Capture the change in `revision_v1`.
3. Verify the boundary with ACP before any settlement or handoff claim.

## 3) Cursor

### Role split
- Cursor is the editing workspace.
- ACP is the accountability trail around the edit.

### Execution point
- Edit files in Cursor.
- Run the ACP command in the terminal connected to the same checkout.

```bash
./scripts/conformance.sh run --reference
```

### Evidence
- The edited files in the working tree
- The verification report in `conformance/out/`
- A short review note that explains why the edit is accepted

### Recipe
1. Make the smallest possible edit in Cursor.
2. Keep the contract artifact separate from the code diff.
3. Attach the verification report after the edit is complete.

## 4) Antigravity

### Role split
- Antigravity acts as the agent runtime or orchestration layer.
- ACP keeps the accountability boundary outside the runtime.

### Execution point
- Run the agent flow in Antigravity.
- Use ACP as the external verification layer around that flow.

```bash
./scripts/conformance.sh run --reference
```

### Evidence
- The agent output or handoff summary
- The ACP report in `conformance/out/`
- A separate note for any revision, evidence, or settlement intent

### Recipe
1. Keep the runtime message stream outside the ACP contract.
2. Convert the important boundary changes into ACP artifacts.
3. Treat the ACP report as the proof layer, not the orchestration layer.

## Quick reference

| Harness | Best use | ACP boundary |
| --- | --- | --- |
| Claude Code | Interactive implementation | Contract, evidence, verification stay in ACP |
| Codex | Short implementation loops | Code change and proof are separated |
| Cursor | Direct editor workflow | Edit surface is separate from accountability trail |
| Antigravity | Agent runtime / orchestration | Runtime stays outside the ACP boundary |

## Why this matters

The same command can validate all of them:

```bash
./scripts/conformance.sh run --reference
```

That is the point of ACP: the tool that executes the work is not the system that explains it.

