# Public Package Index (English)

This folder contains English public-facing documentation.

## Language Navigation
- English index (this file): `docs/en/README.md`
- Japanese index: `docs/ja/README.md`
- Combined EN/JA index: `docs/README.md`

## Included Files
- `00_package_baseline.md`: package-wide editorial baseline
- `01_message_map.md`: audience message map
- `02_launch_copy_bank.md`: launch copy snippets
- `03_demo_script_90s.md`: short demo script and presenter guardrails
- `04_share_faq.md`: share-friendly FAQ
- `05_anchor_use_case.md`: delegated-research anchor use case
- `06_comparison_matrix_short.md`: short responsibility-class matrix
- `07_channel_playbook.md`: channel-specific publishing guide
- `08_demo_script_30s.md`: short-form demo script
- `09_demo_script_3min.md`: technical demo script
- `10_schema_release_plan.md`: phased publication plan
- `11_faq_top5.md`: README-embed friendly FAQ
- `12_readme_repo_ready.md`: repository-ready README text
- `13_objection_memo.md`: objection handling memo
- `14_issue_submission_packet.md`: issue submission form
- `15_real_world_impact.md`: practical impact and adoption guidance
- `16_v1_release_execution_plan.md`: blocker-first release execution plan with DoD
- `17_v1_release_policy.md`: fixed policy for v1 exit criteria and compatibility rules
- `18_security_ops_minimum_runbook.md`: minimum runbook for lock/SBOM/vuln/fail-closed operations
- `19_v1_declaration.md`: v1 establishment declaration and evidence index
- `20_post_v1_roadmap.md`: post-v1 roadmap for maturity and adoption
- `22_harness_implementation_guide.md`: production runner contract and integration guide
- `23_schema_versioning_policy.md`: machine-readable compatibility and versioning policy
- `24_conformance_certification.md`: certification levels, evidence requirements, and badge policy
- `25_integration_patterns.md`: practical ACP integration patterns with adjacent systems
- `26_certification_test_suite.md`: distributable certification suite packaging and evidence model
- `27_python_sdk_quickstart.md`: minimal Python SDK and `acp` CLI quickstart
- `28_conformant_implementation_registry.md`: registry operations and publication flow for conformant implementations
- `29_transport_agnostic_artifact_exchange_protocol.md`: transport-neutral package protocol for exchanging ACP artifacts

## Editorial Intent
- Keep docs concise and boundary-stable.
- Keep public docs aligned to Core-15 and non-replacement framing.

## Release Helper
- Run `./scripts/public_release_check.sh` before publication.
- Run `./scripts/verify_v1_bundle.sh` to reinstall conformance deps and refresh v1 audit evidence under `conformance/out/` (see `19_v1_declaration.md`).
- This repository **is** the public bundle root; it does not include `./scripts/prepare_public_bundle.sh`. If you use a wider ACP development tree, run that tree's packaging script there to copy `release/public_bundle/` to a publish path.
