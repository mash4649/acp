"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseReport = parseReport;
exports.reportSummary = reportSummary;
exports.reportMismatches = reportMismatches;
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
function loadReport(reportOrPath) {
    if (reportOrPath === null || reportOrPath === undefined) {
        throw new Error("report not found: empty input");
    }
    if (typeof reportOrPath === "string") {
        const candidatePath = (0, node_path_1.resolve)(reportOrPath);
        if ((0, node_fs_1.existsSync)(candidatePath)) {
            return JSON.parse((0, node_fs_1.readFileSync)(candidatePath, "utf-8"));
        }
        const trimmed = reportOrPath.trimStart();
        if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
            return JSON.parse(reportOrPath);
        }
        throw new Error(`report not found: ${reportOrPath}`);
    }
    if (typeof reportOrPath === "object") {
        if (Array.isArray(reportOrPath)) {
            return { results: reportOrPath };
        }
        return { ...reportOrPath };
    }
    throw new Error(`report not found: ${String(reportOrPath)}`);
}
function parseReport(reportOrPath) {
    return loadReport(reportOrPath);
}
function reportSummary(reportOrPath) {
    const report = loadReport(reportOrPath);
    const summary = {
        ...(typeof report.summary === "object" && report.summary !== null ? report.summary : {}),
    };
    return {
        ...summary,
        run_id: report.run_id,
        profile_id: report.profile_id,
        status: report.status,
        generated_at: report.generated_at,
    };
}
function reportMismatches(reportOrPath) {
    const report = loadReport(reportOrPath);
    const results = report.results;
    if (!Array.isArray(results)) {
        return [];
    }
    return results
        .filter((result) => typeof result === "object" && result !== null)
        .filter((result) => result.verdict === "mismatch")
        .map((result) => ({ ...result }));
}
