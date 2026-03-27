import assert from "node:assert/strict";
import { resolve } from "node:path";
import { test } from "node:test";

import { buildAgreement } from "../src/builder";
import { validateArtifact } from "../src/validator";

const repoRoot = resolve(process.cwd(), "..", "..", "..");

test("validateArtifact accepts a valid agreement artifact", () => {
  const artifact = buildAgreement("agr-js-demo-001", "2026-03-26T00:00:00Z");
  const errors = validateArtifact(artifact, "agreement", repoRoot);
  assert.deepEqual(errors, []);
});

test("validateArtifact reports schema errors for an invalid agreement artifact", () => {
  const artifact = {
    artifact_type: "agreement_v1",
    schema_version: "1.0.0",
    protocol_version: "1.0",
    agreement_id: "bad id with spaces",
    created_at: "2026-03-26T00:00:00Z",
  };
  const errors = validateArtifact(artifact, "agreement", repoRoot);
  assert.ok(errors.length > 0);
  assert.match(errors[0], /agreement_id/);
});
