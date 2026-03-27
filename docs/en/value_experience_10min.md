# ACP 10-Minute Value Experience

This guide is the fastest way to feel ACP's value in a real repository.

It is intentionally narrow:

- one command
- one success check
- one failure FAQ

## 1) Run one command

From the repository root, run:

```bash
./scripts/conformance.sh run --reference
```

What this does:

- loads the reference runner path
- validates the contract boundary
- writes a verification report into `conformance/out/`

## 2) Confirm success

After the command finishes, check the output directory:

```bash
ls conformance/out
```

You should see a fresh report file such as:

- `report.phase1.json`
- or another `report.*.json` file produced by the current profile

Success means:

- the command exits with status `0`
- a report file exists in `conformance/out/`
- the report contains a pass status and no failed summary items

If you want a stronger visual check, open the report and confirm that the run recorded the expected mode and summary fields.

## 3) Failure FAQ

### The command says `Missing required command`

Install the missing tool first.

- `jq` is required for conformance scripts
- on macOS, install it with your package manager

### The command fails before writing a report

Check whether the repository dependencies were installed.

Try:

```bash
./scripts/install_conformance_deps.sh
```

Then run the reference command again.

### The report exists but the run still failed

Open the report and inspect:

- `status`
- `summary.failed`
- `results`

If the report is not a pass, the issue is usually in the fixture or the local environment, not in the command syntax.

### I want to compare execution and accountability

Use ACP's framing:

- execution is the command that runs the workflow
- accountability is the report that proves what happened

That separation is the point of the 10-minute experience.

## What to remember

- Run one command.
- Check one report.
- Separate execution from accountability.

