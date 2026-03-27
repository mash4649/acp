export type SchemaMap = Record<string, string>;
export type SchemaLookup = string | {
    schema_map?: SchemaMap;
} | SchemaMap;
export declare function validateArtifact(payloadOrPath: unknown, schemaKey: string, repoRootOrSchemaMap: SchemaLookup): string[];
