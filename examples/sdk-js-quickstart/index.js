const { resolve } = require("node:path");

const {
  buildAgreement,
  buildDelegationEdge,
  reportSummary,
  validateArtifact,
} = require("../../sdk/js/acp-sdk-js/dist/src/index.js");

const repoRoot = resolve(__dirname, "../..");

const agreement = buildAgreement("agr-js-quickstart-001", "2026-03-26T00:00:00Z");
const delegation = buildDelegationEdge(
  "agr-js-quickstart-001",
  "rev-js-quickstart-001",
  "edge-js-quickstart-001",
  "rev-parent-001",
  "agr-child-001",
  "rev-child-001",
  "subject-parent",
  "subject-child",
  "2026-03-26T00:01:00Z",
);
const report = {
  run_id: "demo-001",
  profile_id: "phase1-accountability-minimum",
  status: "pass",
  generated_at: "2026-03-26T00:02:00Z",
  summary: { total: 2, passed: 2, failed: 0, notes: ["quickstart"] },
  results: [{ target_id: "agreement_valid", verdict: "match" }],
};

console.log(JSON.stringify({
  agreement_errors: validateArtifact(agreement, "agreement", repoRoot),
  delegation_errors: validateArtifact(delegation, "delegation_edge", repoRoot),
  report_summary: reportSummary(report),
}, null, 2));
