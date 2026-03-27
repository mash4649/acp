# ACP 5-minute Quickstart

This quickstart gets you from a clean checkout to a local conformance run in about 5 minutes.

## Prerequisites
- `python3` 3.11 or newer
- `bash` or `zsh`
- `pip` available for the selected Python interpreter

## 1. Install conformance dependencies

```bash
./scripts/install_conformance_deps.sh
```

This installs the reference-harness dependencies into a versioned repo-local `.tmp/` cache and prefers `requirements-conformance.lock`.

## 2. Check the environment

```bash
./scripts/conformance.sh doctor
```

Expected output:
- The command exits `0`
- The tool reports that the contract, profile files, and local dependencies are readable

## 3. Prepare local artifacts

```bash
./scripts/conformance.sh prepare
```

Expected output:
- `conformance/out/` is created or refreshed
- Request and report scaffolding is generated for the selected profile

## 4. Run the mock gate

```bash
./scripts/conformance.sh run --mock
```

Expected output:
- The run completes without external dependencies
- `conformance/out/` contains the latest mock report and request payloads

## 5. Run the reference gate

```bash
./scripts/conformance.sh run --reference
```

Expected output:
- Schema vectors and invariant cases are evaluated by the repo-local reference harness
- The resulting report status is `pass` for the checked baseline

## Common failure

If the reference run fails with import errors for `jsonschema` or `yaml`, remove `.tmp/conformance-deps` and reinstall the dependencies. That usually means the wheel set was interrupted or installed with an incompatible Python version.

## What to read next
- [Roadmap](../../release/distribution_bundle/docs/en/20_post_v1_roadmap.md)
- [Public docs index](../../release/distribution_bundle/docs/README.md)
