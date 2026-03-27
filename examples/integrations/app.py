from __future__ import annotations

import json
import tempfile
from pathlib import Path
from typing import Any

from fastapi import Body, FastAPI, HTTPException

from .adapter import HarnessConfig, default_runner_path, run_harness


APP_DIR = Path(__file__).resolve().parent
REPO_ROOT = APP_DIR.parents[1]
DEFAULT_CONFIG_PATH = APP_DIR / "config.example.json"
DEFAULT_REQUEST_PATH = APP_DIR / "sample_request.json"

app = FastAPI(
    title="ACP Integration Skeleton",
    version="0.1.0",
    description="Reference FastAPI skeleton that invokes the ACP harness contract adapter.",
)


def load_config(config_path: Path) -> HarnessConfig:
    data = json.loads(config_path.read_text(encoding="utf-8"))
    if "runner_path" not in data:
        data["runner_path"] = str(default_runner_path(REPO_ROOT))
    return HarnessConfig.from_mapping(APP_DIR, data)


def config_from_overrides(overrides: dict[str, Any]) -> HarnessConfig:
    data = json.loads(DEFAULT_CONFIG_PATH.read_text(encoding="utf-8"))
    data.update({key: value for key, value in overrides.items() if value is not None})
    if "runner_path" not in data:
        data["runner_path"] = str(default_runner_path(REPO_ROOT))
    return HarnessConfig.from_mapping(APP_DIR, data)


def request_path_from_body(body: dict[str, Any] | None) -> Path:
    if not body:
        return DEFAULT_REQUEST_PATH
    request_payload = body.get("request_payload")
    if request_payload is None:
        return DEFAULT_REQUEST_PATH
    with tempfile.NamedTemporaryFile("w", suffix=".json", dir=APP_DIR, delete=False, encoding="utf-8") as handle:
        json.dump(request_payload, handle, indent=2)
        handle.write("\n")
        return Path(handle.name)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "mode": "reference-skeleton"}


@app.post("/runs/example")
def run_example() -> dict[str, Any]:
    config = load_config(DEFAULT_CONFIG_PATH)
    return run_harness(config)


@app.post("/runs")
def run_custom(body: dict[str, Any] | None = Body(default=None)) -> dict[str, Any]:
    try:
        payload = body or {}
        config = config_from_overrides(payload.get("config", {}))
        request_path = request_path_from_body(payload)
        if request_path != config.request_path:
            config = HarnessConfig(
                runner_path=config.runner_path,
                contract_path=config.contract_path,
                profile_path=config.profile_path,
                request_path=request_path,
                report_dir=config.report_dir,
            )
        return run_harness(config)
    except (OSError, ValueError, RuntimeError, json.JSONDecodeError) as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
