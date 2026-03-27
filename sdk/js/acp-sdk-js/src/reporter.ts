import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadReport(reportOrPath: unknown): Record<string, unknown> {
  if (reportOrPath === null || reportOrPath === undefined) {
    throw new Error("report not found: empty input");
  }

  if (typeof reportOrPath === "string") {
    const candidatePath = resolve(reportOrPath);
    if (existsSync(candidatePath)) {
      return JSON.parse(readFileSync(candidatePath, "utf-8")) as Record<string, unknown>;
    }

    const trimmed = reportOrPath.trimStart();
    if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
      return JSON.parse(reportOrPath) as Record<string, unknown>;
    }
    throw new Error(`report not found: ${reportOrPath}`);
  }

  if (typeof reportOrPath === "object") {
    if (Array.isArray(reportOrPath)) {
      return { results: reportOrPath };
    }
    return { ...(reportOrPath as Record<string, unknown>) };
  }

  throw new Error(`report not found: ${String(reportOrPath)}`);
}

export function parseReport(reportOrPath: unknown): Record<string, unknown> {
  return loadReport(reportOrPath);
}

export function reportSummary(reportOrPath: unknown): Record<string, unknown> {
  const report = loadReport(reportOrPath);
  const summary = {
    ...(typeof report.summary === "object" && report.summary !== null ? (report.summary as Record<string, unknown>) : {}),
  };

  return {
    ...summary,
    run_id: report.run_id,
    profile_id: report.profile_id,
    status: report.status,
    generated_at: report.generated_at,
  };
}

export function reportMismatches(reportOrPath: unknown): Record<string, unknown>[] {
  const report = loadReport(reportOrPath);
  const results = report.results;
  if (!Array.isArray(results)) {
    return [];
  }

  return results
    .filter((result): result is Record<string, unknown> => typeof result === "object" && result !== null)
    .filter((result) => result.verdict === "mismatch")
    .map((result) => ({ ...result }));
}
