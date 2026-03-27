#!/usr/bin/env python3
"""Repo-local reference harness for ACP conformance."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

import yaml
from jsonschema import Draft202012Validator


ACCEPTANCE_VOCAB = {
    "ACCEPT",
    "PARTIAL_ACCEPT",
    "REJECT",
    "INCONCLUSIVE",
    "PASS",
    "FAIL",
}
PROOF_FINALITY_VOCAB = {"PENDING", "FINAL", "REVOKED", "SUPERSEDED", "DISPUTED"}

IGNORED_ID_FIELDS = {"schema_version", "protocol_version", "binding_version"}


def load_structured(path: Path) -> Any:
    text = path.read_text(encoding="utf-8")
    if path.suffix in {".yaml", ".yml"}:
        return yaml.safe_load(text)
    return json.loads(text)


def to_iso_utc(value: str) -> datetime:
    normalized = value.replace("Z", "+00:00")
    dt = datetime.fromisoformat(normalized)
    if dt.tzinfo is None:
        raise ValueError(f"timestamp must include timezone: {value}")
    return dt.astimezone(timezone.utc)


def artifact_schema_key(artifact: dict[str, Any]) -> str:
    if "artifact_type" in artifact:
        return artifact["artifact_type"].removesuffix("_v1")
    if "binding_type" in artifact:
        return artifact["binding_type"].removesuffix("_v1")
    raise KeyError("artifact has neither artifact_type nor binding_type")


def actual_for_validation(errors: list[str]) -> str:
    return "pass" if not errors else "fail"


@dataclass
class EvalResult:
    actual: str
    message: str
    artifact_refs: list[str]


class ArtifactBundle:
    def __init__(self, artifacts: list[dict[str, Any]]) -> None:
        self.artifacts = artifacts
        self.id_index: dict[str, dict[str, Any]] = {}
        self.type_index: dict[str, list[dict[str, Any]]] = {}
        for artifact in artifacts:
            artifact_type = artifact_schema_key(artifact)
            self.type_index.setdefault(artifact_type, []).append(artifact)
            for key, value in artifact.items():
                if key in IGNORED_ID_FIELDS:
                    continue
                if key.endswith("_id") and isinstance(value, str):
                    self.id_index[value] = artifact

    def by_type(self, artifact_type: str) -> list[dict[str, Any]]:
        return self.type_index.get(artifact_type, [])

    def resolve(self, logical_id: str) -> dict[str, Any] | None:
        return self.id_index.get(logical_id)


def evaluate_delegation_graph_acyclic(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    edges = bundle.by_type("delegation_edge")
    graph: dict[str, set[str]] = {}
    for edge in edges:
        graph.setdefault(edge["parent_revision_id"], set()).add(edge["child_revision_id"])
    visited: set[str] = set()
    stack: set[str] = set()

    def dfs(node: str) -> bool:
        if node in stack:
            return True
        if node in visited:
            return False
        visited.add(node)
        stack.add(node)
        for child in graph.get(node, set()):
            if dfs(child):
                return True
        stack.remove(node)
        return False

    has_cycle = any(dfs(node) for node in graph)
    if has_cycle:
        return EvalResult("fail", "delegation cycle detected", refs)
    return EvalResult("pass", "delegation graph is acyclic", refs)


def evaluate_reservation_coverage(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    edges = bundle.by_type("delegation_edge")
    reservations = bundle.by_type("resource_reservation")
    events = [event for event in bundle.by_type("event") if event.get("event_type") == "REVISION_ACTIVATED"]

    for edge in edges:
        activations = [event for event in events if event.get("revision_id") == edge["child_revision_id"]]
        for activation in activations:
            activation_at = to_iso_utc(activation["created_at"])
            covered = False
            for reservation in reservations:
                if reservation["child_subject_ref"] != edge["child_subject_ref"]:
                    continue
                if reservation["parent_subject_ref"] != edge["parent_subject_ref"]:
                    continue
                if to_iso_utc(reservation["expires_at"]) < activation_at:
                    continue
                covered = True
                break
            if not covered:
                return EvalResult(
                    "fail",
                    f"missing reservation coverage for child activation {activation['event_id']}",
                    refs,
                )
    return EvalResult("pass", "child activation has reservation coverage", refs)


def evaluate_policy_projection_inputs(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    bindings = {item["binding_id"]: item for item in bundle.by_type("data_policy_binding")}
    for projection in bundle.by_type("effective_policy_projection"):
        binding = bindings.get(projection["binding_id"])
        if binding is None:
            return EvalResult(
                "fail",
                f"projection {projection['projection_id']} references missing binding {projection['binding_id']}",
                refs,
            )
        if bundle.resolve(projection["time_fact_ref"]) is None:
            return EvalResult(
                "fail",
                f"projection {projection['projection_id']} references missing time fact {projection['time_fact_ref']}",
                refs,
            )
        if binding["agreement_id"] != projection["agreement_id"] or binding["revision_id"] != projection["revision_id"]:
            return EvalResult(
                "fail",
                f"projection {projection['projection_id']} does not align with binding scope",
                refs,
            )
    return EvalResult("pass", "policy projection inputs are replayable", refs)


def evaluate_time_guards(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    time_facts = {item["time_fact_id"]: item for item in bundle.by_type("time_fact")}
    events = [event for event in bundle.by_type("event") if event.get("event_type") == "REVISION_ACTIVATED"]

    for projection in bundle.by_type("effective_policy_projection"):
        time_fact = time_facts.get(projection["time_fact_ref"])
        if time_fact is None:
            return EvalResult(
                "fail",
                f"projection {projection['projection_id']} references missing time fact {projection['time_fact_ref']}",
                refs,
            )
        observed_at = to_iso_utc(time_fact["observed_at"])
        expires_at = to_iso_utc(time_fact["expires_at"]) if "expires_at" in time_fact else None
        for event in events:
            if event["agreement_id"] != projection["agreement_id"] or event["revision_id"] != projection["revision_id"]:
                continue
            event_at = to_iso_utc(event["created_at"])
            if event_at < observed_at:
                return EvalResult(
                    "fail",
                    f"time fact {time_fact['time_fact_id']} is observed after activation {event['event_id']}",
                    refs,
                )
            if expires_at is not None and event_at > expires_at:
                return EvalResult(
                    "fail",
                    f"time fact {time_fact['time_fact_id']} expired before activation {event['event_id']}",
                    refs,
                )
    return EvalResult("pass", "time guards reference explicit valid time facts", refs)


def evaluate_proof_status(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    for finality in bundle.by_type("proof_finality"):
        status = finality["status"]
        if status in ACCEPTANCE_VOCAB:
            return EvalResult(
                "fail",
                f"proof finality status {status} collapses proof and acceptance vocabulary",
                refs,
            )
        if status not in PROOF_FINALITY_VOCAB:
            return EvalResult(
                "fail",
                f"proof finality status {status} is outside the allowed proof vocabulary",
                refs,
            )
    return EvalResult("pass", "proof finality vocabulary remains separate from acceptance", refs)


def evaluate_proof_references(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    proofs = {item["proof_id"]: item for item in bundle.by_type("proof_artifact")}
    verifiers = {item["verifier_id"]: item for item in bundle.by_type("verifier_descriptor")}
    for finality in bundle.by_type("proof_finality"):
        proof = proofs.get(finality["proof_id"])
        if proof is None:
            return EvalResult(
                "fail",
                f"proof finality {finality['finality_id']} references missing proof {finality['proof_id']}",
                refs,
            )
        verifier = verifiers.get(proof["verifier_ref"])
        if verifier is None:
            return EvalResult(
                "fail",
                f"proof {proof['proof_id']} references missing verifier descriptor {proof['verifier_ref']}",
                refs,
            )
    return EvalResult("pass", "proof finality references existing proof and verifier descriptor", refs)


def evaluate_companion_binding_separation(bundle: ArtifactBundle, refs: list[str]) -> EvalResult:
    companion_types = [
        key
        for key in bundle.type_index
        if key.endswith("_binding")
    ]
    if companion_types:
        if not bundle.by_type("proof_artifact"):
            return EvalResult("fail", "companion bindings cannot replace missing proof artifacts", refs)
        if not bundle.by_type("proof_finality"):
            return EvalResult("fail", "companion bindings cannot replace missing proof finality", refs)
    return EvalResult("pass", "companion bindings remain separate from core proof semantics", refs)


INVARIANT_EVALUATORS: dict[str, Callable[[ArtifactBundle, list[str]], EvalResult]] = {
    "delegation_graph_acyclic": evaluate_delegation_graph_acyclic,
    "reservation_coverage_present_for_child_activation": evaluate_reservation_coverage,
    "policy_projection_inputs_replayable": evaluate_policy_projection_inputs,
    "time_guards_reference_explicit_time_facts": evaluate_time_guards,
    "proof_status_not_collapsed_into_acceptance": evaluate_proof_status,
    "proof_finality_references_existing_proof": evaluate_proof_references,
    "companion_bindings_do_not_replace_core_semantics": evaluate_companion_binding_separation,
}


def resolve_repo_root(contract_path: Path) -> Path:
    return contract_path.resolve().parent.parent


def resolve_path(repo_root: Path, maybe_rel: str) -> Path:
    path = Path(maybe_rel)
    return path if path.is_absolute() else repo_root / path


def load_validator(schema_path: Path) -> Draft202012Validator:
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    return Draft202012Validator(schema)


def schema_key_to_path(repo_root: Path, schema_map: dict[str, str]) -> dict[str, Path]:
    return {key: resolve_path(repo_root, rel) for key, rel in schema_map.items()}


def validate_artifact(artifact_path: Path, validator: Draft202012Validator) -> list[str]:
    artifact = load_structured(artifact_path)
    errors = sorted(validator.iter_errors(artifact), key=lambda item: list(item.path))
    return [error.message for error in errors]


def run_vector_checks(
    repo_root: Path,
    profile: dict[str, Any],
    validators: dict[str, Draft202012Validator],
    schema_paths: dict[str, Path],
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    vectors = profile.get("vectors", {})
    for expected, key in (("pass", "valid"), ("fail", "invalid")):
        for rel_path in vectors.get(key, []):
            artifact_path = resolve_path(repo_root, rel_path)
            try:
                artifact = load_structured(artifact_path)
                schema_key = artifact_schema_key(artifact)
                validator = validators[schema_key]
                errors = sorted(validator.iter_errors(artifact), key=lambda item: list(item.path))
                actual = "pass" if not errors else "fail"
                message = "" if not errors else "; ".join(error.message for error in errors[:3])
            except Exception as exc:  # pragma: no cover - surfaced via report
                schema_key = "unknown"
                actual = "error"
                message = str(exc)
            result = {
                "check_type": "schema",
                "target_id": rel_path,
                "vector_path": rel_path,
                "schema_path": str(schema_paths.get(schema_key, Path("")).relative_to(repo_root)) if schema_key in schema_paths else "",
                "expected": expected,
                "actual": actual,
                "verdict": "match" if actual == expected else "mismatch",
                "artifact_refs": [rel_path],
            }
            if message:
                result["message"] = message
            results.append(result)
    return results


def validate_case_artifacts(
    bundle_artifacts: list[dict[str, Any]],
    validators: dict[str, Draft202012Validator],
) -> list[str]:
    errors: list[str] = []
    for artifact in bundle_artifacts:
        schema_key = artifact_schema_key(artifact)
        validator = validators.get(schema_key)
        if validator is None:
            continue
        case_errors = sorted(validator.iter_errors(artifact), key=lambda item: list(item.path))
        errors.extend(error.message for error in case_errors)
    return errors


def run_case_checks(
    repo_root: Path,
    profile: dict[str, Any],
    validators: dict[str, Draft202012Validator],
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for case_rel in profile.get("cases", []):
        case_dir = resolve_path(repo_root, case_rel)
        expected_path = case_dir / "expected.json"
        expected = json.loads(expected_path.read_text(encoding="utf-8"))
        artifact_files = sorted((case_dir / "artifacts").iterdir())
        artifact_refs = [str(path.relative_to(repo_root)) for path in artifact_files if path.is_file()]
        artifacts = [load_structured(path) for path in artifact_files if path.is_file()]
        structural_errors = validate_case_artifacts(artifacts, validators)
        bundle = ArtifactBundle(artifacts)
        case_results: list[dict[str, Any]] = []
        for expected_result in expected["expected_results"]:
            invariant_id = expected_result["invariant_id"]
            evaluator = INVARIANT_EVALUATORS[invariant_id]
            try:
                if structural_errors:
                    raise ValueError("; ".join(structural_errors))
                outcome = evaluator(bundle, artifact_refs)
                actual = outcome.actual
                message = outcome.message
                refs = outcome.artifact_refs
            except Exception as exc:  # pragma: no cover - surfaced via report
                actual = "error"
                message = str(exc)
                refs = artifact_refs
            verdict = "match" if actual == expected_result["expected"] else "mismatch"
            if verdict == "match" and expected_result.get("message_contains"):
                verdict = "match" if expected_result["message_contains"] in message else "mismatch"
            case_results.append(
                {
                    "check_type": "invariant",
                    "target_id": f"{expected['case_id']}:{invariant_id}",
                    "case_id": expected["case_id"],
                    "invariant_id": invariant_id,
                    "expected": expected_result["expected"],
                    "actual": actual,
                    "verdict": verdict,
                    "artifact_refs": refs,
                    "message": message,
                }
            )
        error_exists = any(item["actual"] == "error" for item in case_results)
        fail_exists = any(item["actual"] == "fail" for item in case_results)
        actual_case_status = "error" if error_exists else "fail" if fail_exists else "pass"
        case_results.append(
            {
                "check_type": "invariant",
                "target_id": f"{expected['case_id']}:case_status_matches_expectation",
                "case_id": expected["case_id"],
                "invariant_id": "case_status_matches_expectation",
                "expected": expected["expected_status"],
                "actual": actual_case_status,
                "verdict": "match" if actual_case_status == expected["expected_status"] else "mismatch",
                "artifact_refs": artifact_refs,
                "message": f"case derived status={actual_case_status}",
            }
        )
        results.extend(case_results)
    return results


def summarize(results: list[dict[str, Any]]) -> tuple[str, dict[str, Any]]:
    mismatch_count = sum(1 for item in results if item["verdict"] == "mismatch")
    error_count = sum(1 for item in results if item["actual"] == "error")
    status = "error" if error_count else "fail" if mismatch_count else "pass"
    summary = {
        "total": len(results),
        "passed": len(results) - mismatch_count,
        "failed": mismatch_count,
        "notes": [
            "Reference harness validates schema vectors and case-based invariants.",
            "Reference harness is a repo-local baseline and not an external authority.",
        ],
    }
    return status, summary


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", required=True)
    parser.add_argument("--profile", required=True)
    parser.add_argument("--request", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()

    contract_path = Path(args.contract)
    profile_path = Path(args.profile)
    request_path = Path(args.request)
    report_path = Path(args.report)
    repo_root = resolve_repo_root(contract_path)

    _contract = json.loads(contract_path.read_text(encoding="utf-8"))
    profile = json.loads(profile_path.read_text(encoding="utf-8"))
    _request = json.loads(request_path.read_text(encoding="utf-8"))
    schema_paths = schema_key_to_path(repo_root, profile.get("schema_map", {}))
    validators = {key: load_validator(path) for key, path in schema_paths.items()}

    results = run_vector_checks(repo_root, profile, validators, schema_paths)
    results.extend(run_case_checks(repo_root, profile, validators))
    status, summary = summarize(results)
    payload = {
        "run_id": f"reference-{profile['profile_id']}",
        "profile_id": profile["profile_id"],
        "status": status,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "summary": summary,
        "results": results,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
