"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateArtifact = validateArtifact;
const _2020_1 = __importDefault(require("ajv/dist/2020"));
const ajv_formats_1 = __importDefault(require("ajv-formats"));
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
const validatorCache = new Map();
function readJson(source) {
    if (source === null || source === undefined) {
        throw new Error("payload not found: empty input");
    }
    if (typeof source === "string") {
        const candidatePath = (0, node_path_1.resolve)(source);
        if ((0, node_fs_1.existsSync)(candidatePath)) {
            return JSON.parse((0, node_fs_1.readFileSync)(candidatePath, "utf-8"));
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
        return { ...source };
    }
    return source;
}
function schemaMapFrom(source) {
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
        return Object.fromEntries(entries.map(([key, value]) => [key, value]));
    }
    return null;
}
function resolveSchemaPath(schemaKey, repoRootOrSchemaMap) {
    const schemaMap = schemaMapFrom(repoRootOrSchemaMap);
    if (schemaMap) {
        const schemaPath = schemaMap[schemaKey];
        if (!schemaPath) {
            throw new Error(schemaKey);
        }
        return (0, node_path_1.resolve)(schemaPath);
    }
    const repoRoot = (0, node_path_1.resolve)(String(repoRootOrSchemaMap));
    const candidates = [
        (0, node_path_1.resolve)(repoRoot, "schemas", "core", `${schemaKey}_v1.schema.json`),
        (0, node_path_1.resolve)(repoRoot, "schemas", "companion", `${schemaKey}_v1.schema.json`),
        (0, node_path_1.resolve)(repoRoot, "schemas", `${schemaKey}_v1.schema.json`),
    ];
    for (const candidate of candidates) {
        if ((0, node_fs_1.existsSync)(candidate)) {
            return candidate;
        }
    }
    throw new Error(`schema not found for ${schemaKey}`);
}
function formatError(error) {
    const path = error.instancePath
        .split("/")
        .filter(Boolean)
        .map((segment) => (segment.match(/^\d+$/) ? `[${segment}]` : `.${segment}`))
        .join("");
    const location = path ? `$${path}` : "$";
    return `${location}: ${error.message ?? "validation failed"}`;
}
function getValidator(schemaPath) {
    const cached = validatorCache.get(schemaPath);
    if (cached) {
        return cached;
    }
    const ajv = new _2020_1.default({ allErrors: true, strict: false });
    (0, ajv_formats_1.default)(ajv);
    const schema = JSON.parse((0, node_fs_1.readFileSync)(schemaPath, "utf-8"));
    const compiled = ajv.compile(schema);
    validatorCache.set(schemaPath, compiled);
    return compiled;
}
function validateArtifact(payloadOrPath, schemaKey, repoRootOrSchemaMap) {
    const payload = readJson(payloadOrPath);
    let schemaPath;
    try {
        schemaPath = resolveSchemaPath(schemaKey, repoRootOrSchemaMap);
    }
    catch (error) {
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
