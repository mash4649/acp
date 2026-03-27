# ACP Integration Skeleton

This directory is a reference skeleton, not production-ready code.

## Architecture

- `app.py`: FastAPI app exposing a minimal conformance trigger endpoint
- `adapter.py`: subprocess wrapper that calls the local ACP harness contract adapter
- `config.example.json`: sample runtime configuration
- `sample_request.json`: sample harness request payload
- `requirements.txt`: explicit Python dependencies for the skeleton

## Contract Flow

1. The API loads a config file or in-memory defaults.
2. The adapter resolves the local `ACP_HARNESS_RUNNER` path.
3. The adapter calls the runner with `--contract`, `--profile`, `--request`, and `--report`.
4. The runner writes a JSON report and the API returns the report path plus parsed summary.

## Run Steps

```bash
python3 -m pip install -r examples/integrations/requirements.txt
uvicorn examples.integrations.app:app --reload
```

Then POST to `/runs/example` or call the service with your own request payload.

## Default Paths

- Contract: `conformance/harness_contract_v1.json`
- Profile: `conformance/profiles/phase1.profile.json`
- Runner: `release/distribution_bundle/scripts/acp_harness_runner.sh`

## Notes

- This is a reference skeleton for adaptation and review.
- It does not manage secrets, retries, queues, or multi-tenant isolation.
- Keep the adapter contract stable before adding production concerns.
