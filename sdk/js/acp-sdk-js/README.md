# acp-sdk-js

`acp-sdk-js` は ACP の最小 TypeScript / JavaScript SDK です。

提供する機能:

- JSON Schema 検証
- ACP アーティファクト生成
- conformance report の要約・mismatch 抽出

## Install

```bash
cd sdk/js/acp-sdk-js
npm ci
```

## Usage examples

### 1. Validate an artifact

```ts
import { buildAgreement, validateArtifact } from "acp-sdk-js";

const agreement = buildAgreement("agr-demo-001", "2026-03-26T00:00:00Z");
const errors = validateArtifact(agreement, "agreement", "../../..");
console.log(errors);
```

### 2. Build a delegated workflow artifact

```ts
import { buildDelegationEdge } from "acp-sdk-js";

const delegation = buildDelegationEdge(
  "agr-parent-001",
  "rev-parent-001",
  "edge-001",
  "rev-parent-001",
  "agr-child-001",
  "rev-child-001",
  "subject-parent",
  "subject-child",
  "2026-03-26T00:00:00Z",
);
console.log(delegation);
```

### 3. Parse a conformance report

```ts
import { reportMismatches, reportSummary } from "acp-sdk-js";

const report = {
  run_id: "demo-001",
  profile_id: "phase1-accountability-minimum",
  status: "fail",
  generated_at: "2026-03-26T00:03:00Z",
  summary: { total: 2, passed: 1, failed: 1, notes: [] },
  results: [
    { target_id: "agreement_valid", verdict: "match" },
    { target_id: "revision_missing_id", verdict: "mismatch", expected: "pass", actual: "fail" },
  ],
};

console.log(reportSummary(report));
console.log(reportMismatches(report));
```

## Scripts

```bash
npm test
npm run lint
```

`npm test` runs the TypeScript build and then executes the compiled Node test files.
