# ACP Value KPIs

This document defines the small set of KPIs used to measure whether ACP adoption is actually improving operational accountability.

Use the same sample window, the same workflow boundary, and the same recording method before and after ACP adoption.

## 1) Audit effort

### Definition
Audit effort is the amount of human time required to answer review, compliance, and post-hoc accountability questions for one workflow item or one batch.

### Formula
`Audit effort = audit prep time + audit follow-up time`

### Unit
- minutes per item
- or hours per batch

### Record when
- after a review or audit completes
- after any follow-up clarification closes

### How to measure
- Start the timer when the reviewer begins gathering evidence.
- Stop the timer when the review packet is complete and the reviewer can answer the audit question set.
- Count follow-up clarifications only if they are needed to resolve responsibility or evidence gaps.

### Why it matters
This KPI shows whether ACP reduces the manual work needed to explain delegated actions later.

## 2) Acceptance lead time

### Definition
Acceptance lead time is the elapsed time from the agreement boundary being fixed to the acceptance decision being recorded.

### Formula
`Acceptance lead time = acceptance_timestamp - agreement_timestamp`

### Unit
- hours
- days

### Record when
- when an agreement is first fixed
- when the accepted or rejected decision is recorded

### How to measure
- Use the same start and end events for both baseline and after-ACP periods.
- Prefer median and p90 values instead of a single best-case example.

### Why it matters
This KPI shows whether ACP shortens the path from request to auditable acceptance.

## 3) Responsibility ambiguity rate

### Definition
Responsibility ambiguity rate is the share of items that require extra clarification because owner, approver, or evidence boundaries are unclear.

### Formula
`Responsibility ambiguity rate = ambiguous_items / total_items`

### Unit
- percent
- or ambiguous items per 100 items

### Record when
- whenever a reviewer has to ask "who owns this?"
- whenever evidence is rejected because the boundary is unclear

### How to measure
- Count one item as ambiguous if it needs a human clarification outside the normal workflow.
- Use the same ambiguity rule in the baseline period and the ACP period.

### Why it matters
This KPI shows whether ACP reduces handoff confusion and makes ownership explicit.

## Measurement rules

- Compare the same workflow class before and after ACP adoption.
- Keep sample size and observation window as close as possible.
- Record the metric definition before the first measurement so the team does not change the rule midstream.
- For public case studies, report the metric name, the formula, the measurement window, and the sample size together.

## Suggested reporting template

| KPI | Formula | Unit | Window | Sample |
| --- | --- | --- | --- | --- |
| Audit effort | `audit prep + follow-up` | min/item | 6 weeks | 38 items |
| Acceptance lead time | `acceptance - agreement` | days | 6 weeks | 38 items |
| Responsibility ambiguity rate | `ambiguous / total` | % | 6 weeks | 38 items |

