import assert from "node:assert/strict";
import { resolve } from "node:path";
import { test } from "node:test";

import {
  buildAgreement,
  buildDelegationEdge,
  buildEvent,
  buildRevision,
} from "../src/builder";
import { reportMismatches, reportSummary } from "../src/reporter";
import { validateArtifact } from "../src/validator";

const repoRoot = resolve(process.cwd(), "..", "..", "..");

test("builders create the expected ACP artifacts", () => {
  const agreement = buildAgreement("agr-js-demo-002", "2026-03-26T00:00:00Z");
  const revision = buildRevision("agr-js-demo-002", "rev-js-demo-001", "2026-03-26T00:01:00Z");
  const event = buildEvent(
    "agr-js-demo-002",
    "rev-js-demo-001",
    "evt-js-demo-001",
    "REVISION_ACTIVATED",
    "2026-03-26T00:02:00Z",
  );
  const delegation = buildDelegationEdge(
    "agr-js-demo-002",
    "rev-js-demo-001",
    "edge-js-demo-001",
    "rev-parent-001",
    "agr-child-001",
    "rev-child-001",
    "subject-parent",
    "subject-child",
    "2026-03-26T00:03:00Z",
  );

  assert.equal(agreement.artifact_type, "agreement_v1");
  assert.equal(revision.revision_id, "rev-js-demo-001");
  assert.equal(event.event_type, "REVISION_ACTIVATED");
  assert.equal(delegation.child_agreement_id, "agr-child-001");

  assert.deepEqual(validateArtifact(agreement, "agreement", repoRoot), []);
  assert.deepEqual(validateArtifact(revision, "revision", repoRoot), []);
  assert.deepEqual(validateArtifact(event, "event", repoRoot), []);
  assert.deepEqual(validateArtifact(delegation, "delegation_edge", repoRoot), []);
});

test("builders can produce invalid payloads when given invalid ids", () => {
  const invalidAgreement = buildAgreement("invalid agreement id", "2026-03-26T00:00:00Z");
  const errors = validateArtifact(invalidAgreement, "agreement", repoRoot);
  assert.ok(errors.some((error) => error.includes("agreement_id")));
});

test("report helpers flatten summaries and isolate mismatches", () => {
  const report = {
    run_id: "demo-001",
    profile_id: "phase1-accountability-minimum",
    status: "fail",
    generated_at: "2026-03-26T00:03:00Z",
    summary: { total: 2, passed: 1, failed: 1, notes: ["example"] },
    results: [
      { target_id: "agreement_valid", verdict: "match" },
      { target_id: "revision_missing_id", verdict: "mismatch", expected: "pass", actual: "fail" },
    ],
  };

  const summary = reportSummary(report);
  const mismatches = reportMismatches(report);
  const brokenMismatches = reportMismatches({ results: "broken" });

  assert.equal(summary.failed, 1);
  assert.equal(summary.run_id, "demo-001");
  assert.equal(mismatches.length, 1);
  assert.equal(mismatches[0].target_id, "revision_missing_id");
  assert.deepEqual(brokenMismatches, []);
});
