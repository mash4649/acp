import Ajv2020, { type ErrorObject } from "ajv/dist/2020";
import addFormats from "ajv-formats";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

export type SchemaMap = Record<string, string>;
export type SchemaLookup = string | { schema_map?: SchemaMap } | SchemaMap;

const validatorCache = new Map<string, ReturnType<Ajv2020["compile"]>>();

function readJson(source: unknown): unknown {
  if (source === null || source === undefined) {
    throw new Error("payload not found: empty input");
  }

  if (typeof source === "string") {
    const candidatePath = resolve(source);
    if (existsSync(candidatePath)) {
      return JSON.parse(readFileSync(candidatePath, "utf-8"));
    }

    const trimmed = source.trimStart();
    if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
      return JSON.parse(source);
    }
    throw new Error(`artifact not found: ${source}`);
  }

  if (Array.isArray(source)) {
    return source.map((value) => readJson(value));
  }

  if (typeof source === "object") {
    return { ...(source as Record<string, unknown>) };
  }

  return source;
}

function schemaMapFrom(source: SchemaLookup): SchemaMap | null {
  if (typeof source !== "object" || source === null || Array.isArray(source)) {
    return null;
  }

  const maybeMap = "schema_map" in source ? source.schema_map : source;
  if (typeof maybeMap !== "object" || maybeMap === null || Array.isArray(maybeMap)) {
    return null;
  }

  const entries = Object.entries(maybeMap);
  if (!entries.length) {
    return {};
  }

  if (entries.every(([, value]) => typeof value === "string")) {
    return Object.fromEntries(entries.map(([key, value]) => [key, value])) as SchemaMap;
  }

  return null;
}

function resolveSchemaPath(schemaKey: string, repoRootOrSchemaMap: SchemaLookup): string {
  const schemaMap = schemaMapFrom(repoRootOrSchemaMap);
  if (schemaMap) {
    const schemaPath = schemaMap[schemaKey];
    if (!schemaPath) {
      throw new Error(schemaKey);
    }
    return resolve(schemaPath);
  }

  const repoRoot = resolve(String(repoRootOrSchemaMap));
  const candidates = [
    resolve(repoRoot, "schemas", "core", `${schemaKey}_v1.schema.json`),
    resolve(repoRoot, "schemas", "companion", `${schemaKey}_v1.schema.json`),
    resolve(repoRoot, "schemas", `${schemaKey}_v1.schema.json`),
  ];

  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      return candidate;
    }
  }

  throw new Error(`schema not found for ${schemaKey}`);
}

function formatError(error: ErrorObject): string {
  const path = error.instancePath
    .split("/")
    .filter(Boolean)
    .map((segment) => (segment.match(/^\d+$/) ? `[${segment}]` : `.${segment}`))
    .join("");

  const location = path ? `$${path}` : "$";
  return `${location}: ${error.message ?? "validation failed"}`;
}

function getValidator(schemaPath: string) {
  const cached = validatorCache.get(schemaPath);
  if (cached) {
    return cached;
  }

  const ajv = new Ajv2020({ allErrors: true, strict: false });
  addFormats(ajv);
  const schema = JSON.parse(readFileSync(schemaPath, "utf-8"));
  const compiled = ajv.compile(schema);
  validatorCache.set(schemaPath, compiled);
  return compiled;
}

export function validateArtifact(
  payloadOrPath: unknown,
  schemaKey: string,
  repoRootOrSchemaMap: SchemaLookup,
): string[] {
  const payload = readJson(payloadOrPath);

  let schemaPath: string;
  try {
    schemaPath = resolveSchemaPath(schemaKey, repoRootOrSchemaMap);
  } catch (error) {
    return [error instanceof Error ? error.message : String(error)];
  }

  const validator = getValidator(schemaPath);
  if (validator(payload)) {
    return [];
  }

  return (validator.errors ?? []).slice().sort((left, right) => {
    const leftPath = left.instancePath;
    const rightPath = right.instancePath;
    return leftPath === rightPath ? (left.message ?? "").localeCompare(right.message ?? "") : leftPath.localeCompare(rightPath);
  }).map(formatError);
}
