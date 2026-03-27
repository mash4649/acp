"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const strict_1 = __importDefault(require("node:assert/strict"));
const node_path_1 = require("node:path");
const node_test_1 = require("node:test");
const builder_1 = require("../src/builder");
const reporter_1 = require("../src/reporter");
const validator_1 = require("../src/validator");
const repoRoot = (0, node_path_1.resolve)(process.cwd(), "..", "..", "..");
(0, node_test_1.test)("builders create the expected ACP artifacts", () => {
    const agreement = (0, builder_1.buildAgreement)("agr-js-demo-002", "2026-03-26T00:00:00Z");
    const revision = (0, builder_1.buildRevision)("agr-js-demo-002", "rev-js-demo-001", "2026-03-26T00:01:00Z");
    const event = (0, builder_1.buildEvent)("agr-js-demo-002", "rev-js-demo-001", "evt-js-demo-001", "REVISION_ACTIVATED", "2026-03-26T00:02:00Z");
    const delegation = (0, builder_1.buildDelegationEdge)("agr-js-demo-002", "rev-js-demo-001", "edge-js-demo-001", "rev-parent-001", "agr-child-001", "rev-child-001", "subject-parent", "subject-child", "2026-03-26T00:03:00Z");
    strict_1.default.equal(agreement.artifact_type, "agreement_v1");
    strict_1.default.equal(revision.revision_id, "rev-js-demo-001");
    strict_1.default.equal(event.event_type, "REVISION_ACTIVATED");
    strict_1.default.equal(delegation.child_agreement_id, "agr-child-001");
    strict_1.default.deepEqual((0, validator_1.validateArtifact)(agreement, "agreement", repoRoot), []);
    strict_1.default.deepEqual((0, validator_1.validateArtifact)(revision, "revision", repoRoot), []);
    strict_1.default.deepEqual((0, validator_1.validateArtifact)(event, "event", repoRoot), []);
    strict_1.default.deepEqual((0, validator_1.validateArtifact)(delegation, "delegation_edge", repoRoot), []);
});
(0, node_test_1.test)("builders can produce invalid payloads when given invalid ids", () => {
    const invalidAgreement = (0, builder_1.buildAgreement)("invalid agreement id", "2026-03-26T00:00:00Z");
    const errors = (0, validator_1.validateArtifact)(invalidAgreement, "agreement", repoRoot);
    strict_1.default.ok(errors.some((error) => error.includes("agreement_id")));
});
(0, node_test_1.test)("report helpers flatten summaries and isolate mismatches", () => {
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
    const summary = (0, reporter_1.reportSummary)(report);
    const mismatches = (0, reporter_1.reportMismatches)(report);
    const brokenMismatches = (0, reporter_1.reportMismatches)({ results: "broken" });
    strict_1.default.equal(summary.failed, 1);
    strict_1.default.equal(summary.run_id, "demo-001");
    strict_1.default.equal(mismatches.length, 1);
    strict_1.default.equal(mismatches[0].target_id, "revision_missing_id");
    strict_1.default.deepEqual(brokenMismatches, []);
});
