# ACP Integration Pattern Catalog

This catalog shows practical ways to combine ACP with adjacent systems without collapsing ACP into orchestration, transport, or settlement.

## 1. MCP + ACP

### Boundary
- MCP handles tool discovery and message exchange.
- ACP handles the agreement, revision, evidence, verification, and settlement boundary.
- Do not use MCP messages as the contract record.

### Artifact Flow
- MCP session starts the task.
- ACP `agreement_v1` captures the delegated scope.
- ACP `revision_v1` records changes to that scope.
- ACP `event_v1` records causally ordered execution milestones.
- ACP `evidence_pack_v1` and `verification_report_v1` bind claims to evidence.

### Failure Handling
- If the MCP session is interrupted, keep the ACP record intact and emit a new revision or dispute event if work resumes.
- If tool output is missing evidence, mark verification incomplete instead of rewriting the task as accepted.
- If the tool graph changes, do not mutate prior ACP artifacts in place.

### Minimal Adoption Path
- Start with one MCP tool call wrapped by one ACP agreement.
- Emit one revision when the tool set or scope changes.
- Add evidence and verification only for outcomes that matter to release or settlement.

## 2. A2A + ACP

### Boundary
- A2A handles agent-to-agent exchange.
- ACP records accountability for what was agreed, changed, verified, and settled.
- Do not treat A2A envelopes as proof of authorization.

### Artifact Flow
- A2A message negotiates intent.
- ACP `agreement_v1` fixes the delegated boundary.
- ACP `delegation_edge_v1` captures parent/child responsibility.
- ACP `time_fact_v1` and `effective_policy_projection_v1` make replayable decisions explicit.
- ACP `settlement_intent_v1` stays separate from verification.

### Failure Handling
- If a child agent acts outside the delegated scope, open a dispute and freeze the relevant boundary.
- If time-sensitive policy is ambiguous, reject the projection until `time_fact_v1` is explicit.
- If multiple agents claim the same authority, resolve it in ACP instead of in transport metadata.

### Minimal Adoption Path
- Use one parent agreement and one child delegation edge.
- Add time facts only when the workflow depends on schedule or observation time.
- Add settlement intent only after verification is complete.

## 3. Workflow Engine + ACP

### Boundary
- The workflow engine coordinates steps.
- ACP stores the auditable boundary and evidence trail for the work.
- Do not let workflow state become the only record of accountability.

### Artifact Flow
- Workflow engine starts a job.
- ACP `agreement_v1` defines the delegated work.
- ACP `revision_v1` records workflow changes or replans.
- ACP `event_v1` marks state transitions that matter to review.
- ACP `freeze_record_v1` records blocked or disputed paths.

### Failure Handling
- If the workflow retries a task, keep retries as workflow state and only emit ACP events for meaningful boundary changes.
- If a step fails but evidence exists, record the failure and preserve the evidence pack.
- If the engine rolls back, do not roll back ACP history; append compensating artifacts instead.

### Minimal Adoption Path
- Wrap one critical workflow with a single ACP agreement.
- Emit events only for transitions that affect authorization, evidence, or settlement.
- Add freeze/dispute artifacts only when the workflow leaves the happy path.

## 4. Payment Rail + ACP

### Boundary
- Payment rails move value.
- ACP records the conditions under which settlement is allowed.
- Do not use ACP as the money movement layer.

### Artifact Flow
- ACP `verification_report_v1` confirms the outcome.
- ACP `settlement_intent_v1` describes what should happen on the rail.
- The rail executes transfer or release.
- ACP `event_v1` and `freeze_record_v1` record the decision and any block.

### Failure Handling
- If settlement fails, keep the verification record and mark settlement separately.
- If the rail returns partial success, emit a new settlement intent rather than editing the old one.
- If a dispute is opened, freeze future settlement actions until the boundary is resolved.

### Minimal Adoption Path
- Start with one settlement intent after one successful verification.
- Keep rail execution idempotent and externally observable.
- Introduce partial release or dispute handling only when the business case requires it.

## Anti-Patterns
- Using ACP as a message bus or task runner.
- Encoding settlement status inside transport envelopes.
- Rewriting old ACP artifacts instead of appending new ones.
- Treating verification success as automatic settlement approval.
- Letting platform-specific metadata replace explicit agreement or evidence artifacts.

## Interoperability Guardrails
- Keep contract, evidence, and settlement artifacts separate.
- Prefer append-only history over mutable state.
- Resolve relative paths and timestamps explicitly.
- Validate each artifact against the relevant schema before using it in a higher-level flow.
- If a system cannot preserve ACP boundaries, add a thin adapter instead of weakening ACP semantics.
