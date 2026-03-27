# ACP Case Studies

This page collects short, anonymized adoption examples for ACP.

The first three sections below are quantified pilot snapshots. They are intentionally short, and they are meant to be replaced with your own measured values before public publishing if you have field data.

## 1) Hiring

### Context
- Recruiting team
- 6-week pilot
- 38 candidate packets
- Same ATS, same review team, same approval chain

### Measurement conditions
- Baseline measured before ACP on the existing chat + spreadsheet workflow
- After measured after introducing `agreement_v1`, `revision_v1`, `verification_report_v1`
- Same team members and same hiring volume in both periods

### Before / After

| Metric | Before | After | Change |
| --- | --- | --- | --- |
| Audit prep time per candidate | 42 min | 12 min | -71% |
| Clarification loops per requisition | 4.8 | 1.4 | -71% |
| Post-decision audit note turnaround | 2.5 days | 0.8 days | -68% |

### Reproduction outline
1. Wrap one hiring batch with a single `agreement_v1`.
2. Record scope changes with `revision_v1`.
3. Attach `verification_report_v1` after decision points and compare the average review time across the same batch size.

## 2) Outsourced production

### Context
- Small agency project
- 2 client projects
- 11 handoffs
- Same delivery team and same client approval chain

### Measurement conditions
- Baseline measured on the existing request / revision / billing workflow
- After measured after introducing `agreement_v1`, `delegation_edge_v1`, `settlement_intent_v1`, and `verification_report_v1`
- The comparison used the same handoff count and the same class of deliverables

### Before / After

| Metric | Before | After | Change |
| --- | --- | --- | --- |
| Scope clarification rounds | 3.6 | 1.7 | -53% |
| Acceptance lead time | 2.9 days | 1.2 days | -59% |
| Payment dispute follow-up tickets | 4 per quarter | 1 per quarter | -75% |

### Reproduction outline
1. Freeze the original request with `agreement_v1`.
2. Track client-directed changes with `revision_v1` and delegated handoffs with `delegation_edge_v1`.
3. Emit `settlement_intent_v1` only after verification, then compare acceptance timing and dispute counts.

## 3) Internal multi-agent

### Context
- Internal delegated-agent workflow
- 4 workflows
- 22 delegated tasks
- Same parent team and the same child-agent routing rules

### Measurement conditions
- Baseline measured before ACP with ad hoc handoffs and manual review notes
- After measured after adding `agreement_v1`, `delegation_edge_v1`, `resource_reservation_v1`, and `freeze_record_v1`
- The comparison used the same class of delegated work and the same review window

### Before / After

| Metric | Before | After | Change |
| --- | --- | --- | --- |
| Unsafe branch freeze time | 35 min | 8 min | -77% |
| Ownership ambiguity tickets | 9 per month | 2 per month | -78% |
| Evidence reconstruction time | 75 min | 18 min | -76% |

### Reproduction outline
1. Place the parent workflow under one `agreement_v1`.
2. Connect child work through `delegation_edge_v1` and reserve shared resources with `resource_reservation_v1`.
3. Use `freeze_record_v1` when a branch becomes unsafe, then compare freeze response time and evidence recovery time before/after.

## 4) Research
- An investigation workflow used `agreement_v1`, `evidence_pack_v1`, and `verification_report_v1` to keep claims tied to evidence.
- Result: reviewers could trace conclusions back to source material without reconstructing the process from chat logs.

## 5) Marketing
- A campaign team used `agreement_v1`, `event_v1`, and `settlement_intent_v1` to record who approved launch and who authorized follow-up actions.
- Result: incident review after a campaign change was faster because the approval boundary was explicit.

## Notes
- All examples are anonymized and intentionally short.
- These are reference patterns, not universal policy templates.

