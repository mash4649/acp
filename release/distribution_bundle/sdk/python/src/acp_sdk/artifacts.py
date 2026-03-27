"""Small helpers for building core ACP artifacts."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

DEFAULT_PROTOCOL_VERSION = "1.0"
DEFAULT_SCHEMA_VERSION = "1.0.0"


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _base_artifact(
    artifact_type: str,
    *,
    schema_version: str = DEFAULT_SCHEMA_VERSION,
    protocol_version: str = DEFAULT_PROTOCOL_VERSION,
    created_at: str | None = None,
) -> dict[str, str]:
    return {
        "artifact_type": artifact_type,
        "schema_version": schema_version,
        "protocol_version": protocol_version,
        "created_at": created_at or _utc_now(),
    }


def build_agreement(
    agreement_id: str,
    created_at: str | None = None,
    *,
    schema_version: str = DEFAULT_SCHEMA_VERSION,
    protocol_version: str = DEFAULT_PROTOCOL_VERSION,
) -> dict[str, str]:
    """Build a minimal `agreement_v1` artifact."""

    artifact = _base_artifact(
        "agreement_v1",
        schema_version=schema_version,
        protocol_version=protocol_version,
        created_at=created_at,
    )
    artifact["agreement_id"] = agreement_id
    return artifact


def build_revision(
    agreement_id: str,
    revision_id: str,
    created_at: str | None = None,
    *,
    schema_version: str = DEFAULT_SCHEMA_VERSION,
    protocol_version: str = DEFAULT_PROTOCOL_VERSION,
) -> dict[str, str]:
    """Build a minimal `revision_v1` artifact."""

    artifact = _base_artifact(
        "revision_v1",
        schema_version=schema_version,
        protocol_version=protocol_version,
        created_at=created_at,
    )
    artifact["agreement_id"] = agreement_id
    artifact["revision_id"] = revision_id
    return artifact


def build_event(
    agreement_id: str,
    revision_id: str,
    event_id: str,
    event_type: str = "REVISION_ACTIVATED",
    created_at: str | None = None,
    *,
    schema_version: str = DEFAULT_SCHEMA_VERSION,
    protocol_version: str = DEFAULT_PROTOCOL_VERSION,
) -> dict[str, str]:
    """Build a minimal `event_v1` artifact."""

    artifact = _base_artifact(
        "event_v1",
        schema_version=schema_version,
        protocol_version=protocol_version,
        created_at=created_at,
    )
    artifact["agreement_id"] = agreement_id
    artifact["revision_id"] = revision_id
    artifact["event_id"] = event_id
    artifact["event_type"] = event_type
    return artifact
