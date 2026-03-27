Status: Draft
Type: Reference
Source of truth: /Users/mbp/Public/dev/mash4649/ACP/出力/ACP v1.0 最終稿.txt
Last aligned with: ACP v1.0 Final-Revised Draft

# Short Comparison Matrix

This table compares responsibility classes, not protocol-level parity targets.

| Axis | ACP | MCP | A2A | Workflow Engine | Payment Rail |
|---|---|---|---|---|---|
| Primary purpose | Delegated-work accountability | Tool/context access | Agent communication | Execution orchestration | Value movement/finality |
| Execution | External | Partial | Partial | Native | No |
| Transport | External | Native | Native | Partial | Partial |
| Contract model | Native governed revision | No | No | Partial | No |
| Evidence model | Native evidence_pack | No | No | Partial | Partial receipt only |
| Verification semantics | Native integrity+acceptance | No | No | Partial | Partial tx-validity |
| Settlement semantics | Native intent layer | No | No | Partial | Native rail semantics |
| Verification != Settlement | Explicit/Native | No | No | Rare | Usually not explicit |
| Delegation/reservation safety | Native/Core | No | Partial | Partial | No |
| Replayable policy + time facts | Native/Core | No | No | Partial | No |
| Dispute/freeze semantics | Native/Core hook | No | No | Partial | Partial hold/escrow |
| Proof abstraction | Native/Core abstraction | No | No | Partial | No |

## One-line takeaway
ACP complements the stack by standardizing accountability semantics; it does not replace transport, execution, or payment layers.

