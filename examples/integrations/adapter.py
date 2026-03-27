from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class HarnessConfig:
    runner_path: Path
    contract_path: Path
    profile_path: Path
    request_path: Path
    report_dir: Path

    @classmethod
    def from_mapping(cls, base_dir: Path, data: dict[str, Any]) -> "HarnessConfig":
        def resolve(key: str) -> Path:
            value = data[key]
            if not isinstance(value, str) or not value:
                raise ValueError(f"{key} must be a non-empty string")
            path = Path(value)
            return path if path.is_absolute() else (base_dir / path).resolve()

        return cls(
            runner_path=resolve("runner_path"),
            contract_path=resolve("contract_path"),
            profile_path=resolve("profile_path"),
            request_path=resolve("request_path"),
            report_dir=resolve("report_dir"),
        )


def default_runner_path(repo_root: Path) -> Path:
    return (repo_root / "release/public_bundle/scripts/acp_harness_runner.sh").resolve()


def run_harness(config: HarnessConfig) -> dict[str, Any]:
    config.report_dir.mkdir(parents=True, exist_ok=True)
    report_path = config.report_dir / f"{config.profile_path.stem}.report.json"
    command = [
        str(config.runner_path),
        "--contract",
        str(config.contract_path),
        "--profile",
        str(config.profile_path),
        "--request",
        str(config.request_path),
        "--report",
        str(report_path),
    ]
    completed = subprocess.run(command, check=False, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RuntimeError(
            "ACP harness runner failed",
            {
                "returncode": completed.returncode,
                "stdout": completed.stdout,
                "stderr": completed.stderr,
                "command": command,
            },
        )
    report = json.loads(report_path.read_text(encoding="utf-8"))
    return {
        "report_path": str(report_path),
        "report": report,
        "stdout": completed.stdout,
        "stderr": completed.stderr,
    }
