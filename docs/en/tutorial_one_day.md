# ACP in One Day

This tutorial shows a practical path to integrate ACP into an existing system in one day.

## 1. Pick one flow
Choose one user-facing workflow that already has a clear handoff, such as:
- hiring review
- outsourced production
- research verification
- marketing approval
- internal multi-agent delegation

Start with a single agreement boundary and do not try to model the entire company.

## 2. Map the minimum artifacts
Use only the artifacts you need for the first pass:
- `agreement_v1` for the contract boundary
- `revision_v1` for change tracking
- `event_v1` for causal activation
- `evidence_pack_v1` or `verification_report_v1` when review evidence matters
- `delegation_edge_v1`, `resource_reservation_v1`, or `settlement_intent_v1` when the workflow needs delegation or handoff control

## 3. Start from an example bundle
Copy the closest starter bundle from `examples/`:
- `examples/minimal-task/`
- `examples/delegated-research/`
- `examples/templates/`

Then rename identifiers and update timestamps so the bundle matches your workflow.

## 4. Validate locally
Run the repository example validator against the copied bundle.

```bash
./scripts/validate_examples.sh examples/minimal-task
```

If the bundle fails validation, fix the artifact shape before adding any new workflow logic.

## 5. Add the first operational rule
The first useful rule is usually one of these:
- no child work starts without a parent agreement
- evidence must be attached before review
- reservation must exist before delegation is activated
- settlement intent must be explicit and separate from verification

Keep the rule simple enough that the team can apply it manually before automating it.

## 6. Roll out incrementally
After the first flow works:
- add one more workflow
- document the exact artifact mapping
- keep the approval boundary explicit

ACP adoption is easier when the first implementation is small, visible, and auditable.
