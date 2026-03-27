SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

.DEFAULT_GOAL := help

.PHONY: help doctor prepare conformance-mock conformance-reference conformance-phase1 conformance-phase2 conformance-phase3 public-check validate-examples cross-version-compat schema-diff-last render-registry

help:
	@printf '%s\n' \
		'ACP developer targets:' \
		'  make doctor               - run the conformance doctor check' \
		'  make prepare              - prepare conformance request/report scaffolding' \
		'  make conformance-mock     - run the mock conformance gate' \
		'  make conformance-reference   - run the reference gate across phase1/2/3' \
		'  make conformance-phase1   - run the phase1 reference gate' \
		'  make conformance-phase2   - run the phase2 reference gate' \
		'  make conformance-phase3   - run the phase3 reference gate' \
		'  make public-check         - run the public release guardrail check' \
		'  make validate-examples    - validate example YAML/JSON bundles' \
		'  make cross-version-compat - run report compatibility suite (F-2)' \
		'  make schema-diff-last     - generate schema changelog vs HEAD~1 (F-3)' \
		'  make render-registry      - render conformant implementation registry page (G-3)'

doctor:
	./scripts/conformance.sh doctor

prepare:
	./scripts/conformance.sh prepare

conformance-mock:
	ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh

conformance-reference:
	@set -euo pipefail; \
	for profile in \
		conformance/profiles/phase1.profile.json \
		conformance/profiles/phase2.profile.json \
		conformance/profiles/phase3.profile.json; do \
		echo "==> $$profile"; \
		ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE="$$profile" ./scripts/conformance_ci.sh; \
	done

conformance-phase1:
	ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase1.profile.json ./scripts/conformance_ci.sh

conformance-phase2:
	ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh

conformance-phase3:
	ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase3.profile.json ./scripts/conformance_ci.sh

public-check:
	./scripts/public_release_check.sh

validate-examples:
	./scripts/validate_examples.sh

cross-version-compat:
	./scripts/cross_version_compat.sh

schema-diff-last:
	./scripts/schema_diff.sh --old HEAD~1 --new HEAD

render-registry:
	./scripts/render_conformance_registry.sh
