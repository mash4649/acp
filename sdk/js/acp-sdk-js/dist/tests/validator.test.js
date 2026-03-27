"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const strict_1 = __importDefault(require("node:assert/strict"));
const node_path_1 = require("node:path");
const node_test_1 = require("node:test");
const builder_1 = require("../src/builder");
const validator_1 = require("../src/validator");
const repoRoot = (0, node_path_1.resolve)(process.cwd(), "..", "..", "..");
(0, node_test_1.test)("validateArtifact accepts a valid agreement artifact", () => {
    const artifact = (0, builder_1.buildAgreement)("agr-js-demo-001", "2026-03-26T00:00:00Z");
    const errors = (0, validator_1.validateArtifact)(artifact, "agreement", repoRoot);
    strict_1.default.deepEqual(errors, []);
});
(0, node_test_1.test)("validateArtifact reports schema errors for an invalid agreement artifact", () => {
    const artifact = {
        artifact_type: "agreement_v1",
        schema_version: "1.0.0",
        protocol_version: "1.0",
        agreement_id: "bad id with spaces",
        created_at: "2026-03-26T00:00:00Z",
    };
    const errors = (0, validator_1.validateArtifact)(artifact, "agreement", repoRoot);
    strict_1.default.ok(errors.length > 0);
    strict_1.default.match(errors[0], /agreement_id/);
});
