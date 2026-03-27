#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_OUT_ROOT="$ROOT_DIR/.tmp/certification-suite"

LEVEL=""
OUT_ROOT="$DEFAULT_OUT_ROOT"

usage() {
  cat <<USAGE
Usage:
  ./scripts/export_certification_suite.sh --level <level1|level2|level3> [--out-root <dir>]

Builds a distributable certification suite directory and tarball:
  <out-root>/ACP-certification-suite-<level>/
  <out-root>/ACP-certification-suite-<level>.tar.gz

The exported suite includes:
  - conformance/ (contract, profiles, vectors, cases, templates)
  - schemas/
  - scripts/
  - LICENSE
  - requirements-conformance.lock
  - optional requirements-conformance.txt when present
USAGE
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Missing required command: $1"
  fi
}

level_to_phase() {
  case "$1" in
    level1) printf '%s\n' phase1 ;;
    level2) printf '%s\n' phase2 ;;
    level3) printf '%s\n' phase3 ;;
    *) return 1 ;;
  esac
}

level_to_profile_rel() {
  printf 'conformance/profiles/%s.profile.json\n' "$(level_to_phase "$1")"
}

json_array() {
  if (($# == 0)); then
    printf '[]\n'
    return
  fi
  printf '%s\n' "$@" | jq -R . | jq -s .
}

copy_dir() {
  local src_rel="$1"
  local dest_rel="$2"
  local src_path="$ROOT_DIR/$src_rel"
  local dest_path="$STAGING_PACKAGE/$dest_rel"

  [[ -d "$src_path" ]] || die "Missing required directory: $src_rel"
  mkdir -p "$(dirname "$dest_path")"
  cp -R "$src_path" "$dest_path"
}

copy_file() {
  local src_rel="$1"
  local dest_rel="$2"
  local src_path="$ROOT_DIR/$src_rel"
  local dest_path="$STAGING_PACKAGE/$dest_rel"

  [[ -f "$src_path" ]] || die "Missing required file: $src_rel"
  mkdir -p "$(dirname "$dest_path")"
  cp "$src_path" "$dest_path"
}

write_package_readme() {
  local profile_rel="$1"
  local profile_id="$2"
  local phase="$3"
  local vector_manifest_rel="$4"
  local valid_count="$5"
  local invalid_count="$6"
  local case_count="$7"
  local schema_count="$8"
  local generated_at="$9"
  local requirements_note="requirements-conformance.lock is the primary dependency input."
  if [[ -f "$ROOT_DIR/requirements-conformance.txt" ]]; then
    requirements_note="requirements-conformance.lock is the primary dependency input; requirements-conformance.txt is included as a fallback reference."
  fi
  local vector_manifest_display="${vector_manifest_rel:-none}"

  cat > "$STAGING_PACKAGE/README.md" <<'README'
# ACP Certification Suite Package (__LEVEL__)

This archive is a distributable certification suite baseline for __LEVEL__.
It is mapped to __PHASE__ and ships the assets needed to run conformance checks outside the source repository.

## Selected Profile
- Level: __LEVEL__
- Phase: __PHASE__
- Profile: __PROFILE_REL__
- Profile ID: __PROFILE_ID__
- Vector manifest: __VECTOR_MANIFEST_REL__
- Generated at: __GENERATED_AT__ UTC

## Included Content
- `conformance/` with the contract, profiles, vectors, cases, templates, and package-local metadata
- `schemas/` with the schema catalog and vector fixtures
- `scripts/` with the conformance runner and helper scripts
- `LICENSE`
- `requirements-conformance.lock`
- `requirements-conformance.txt` if present in the source tree
- `manifest.json` for machine-readable package metadata

## Local Run Commands
From the unpacked package root:

```bash
./scripts/conformance.sh doctor --profile __PROFILE_REL__
./scripts/conformance.sh prepare --profile __PROFILE_REL__
./scripts/conformance.sh run --reference --profile __PROFILE_REL__
ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run --profile __PROFILE_REL__
```

If you want the mock adapter path instead of a real runner:

```bash
./scripts/conformance.sh run --mock --profile __PROFILE_REL__
```

## Evidence Expectations
- `doctor: ok` from `./scripts/conformance.sh doctor --profile __PROFILE_REL__`
- A report file written under `conformance/out/` whose `profile_id` matches __PROFILE_ID__
- `status` should be `pass` for reference or external runs, with `failed = 0`
- Preserve the generated report, the run request, and the stdout/stderr log as evidence

## Package Notes
- `conformance/out/` is intentionally excluded from the export and is generated during runs
- __REQUIREMENTS_NOTE__
- Package counts for this export:
  - schemas: __SCHEMA_COUNT__
  - vectors: __VECTORS_TOTAL__ total (__VALID_COUNT__ valid / __INVALID_COUNT__ invalid)
  - cases: __CASE_COUNT__

## Machine-Readable Metadata
See `manifest.json` for the package inventory and selection metadata.
README

  perl -0pi -e "s#__LEVEL__#$LEVEL#g; s#__PHASE__#$phase#g; s#__PROFILE_REL__#$profile_rel#g; s#__PROFILE_ID__#$profile_id#g; s#__VECTOR_MANIFEST_REL__#$vector_manifest_display#g; s#__GENERATED_AT__#$generated_at#g; s#__REQUIREMENTS_NOTE__#$requirements_note#g; s#__SCHEMA_COUNT__#$schema_count#g; s#__VECTORS_TOTAL__#$((valid_count + invalid_count))#g; s#__VALID_COUNT__#$valid_count#g; s#__INVALID_COUNT__#$invalid_count#g; s#__CASE_COUNT__#$case_count#g" "$STAGING_PACKAGE/README.md"
}

write_manifest() {
  local profile_rel="$1"
  local profile_id="$2"
  local phase="$3"
  local vector_manifest_rel="$4"
  local valid_count="$5"
  local invalid_count="$6"
  local case_count="$7"
  local schema_count="$8"
  local generated_at="$9"
  local has_requirements_txt="$10"

  local included_paths=(
    "README.md"
    "manifest.json"
    "LICENSE"
    "requirements-conformance.lock"
    "conformance/"
    "schemas/"
    "scripts/"
  )
  if [[ "$has_requirements_txt" == "true" ]]; then
    included_paths+=("requirements-conformance.txt")
  fi

  jq -n \
    --arg suite_name "ACP certification suite" \
    --arg level "$LEVEL" \
    --arg phase "$phase" \
    --arg profile_rel "$profile_rel" \
    --arg profile_id "$profile_id" \
    --arg vector_manifest_rel "$vector_manifest_rel" \
    --arg generated_at "$generated_at" \
    --argjson schema_count "$schema_count" \
    --argjson valid_count "$valid_count" \
    --argjson invalid_count "$invalid_count" \
    --argjson case_count "$case_count" \
    --argjson included_paths "$(json_array "${included_paths[@]}")" \
    '{
      suite_name: $suite_name,
      level: $level,
      phase: $phase,
      profile: {
        path: $profile_rel,
        profile_id: $profile_id
      },
      vector_manifest: (if $vector_manifest_rel == "" then null else $vector_manifest_rel end),
      generated_at_utc: $generated_at,
      inventory: {
        schemas: $schema_count,
        vectors_valid: $valid_count,
        vectors_invalid: $invalid_count,
        vectors_total: ($valid_count + $invalid_count),
        cases: $case_count
      },
      included_paths: $included_paths,
      notes: [
        "conformance/out is intentionally excluded from the export",
        "The package is level-scoped through the selected profile"
      ]
    }' > "$STAGING_PACKAGE/manifest.json"
}

main() {
  while (($# > 0)); do
    case "$1" in
      --level)
        [[ $# -ge 2 ]] || die "--level requires a value"
        LEVEL="$2"
        shift 2
        ;;
      --out-root)
        [[ $# -ge 2 ]] || die "--out-root requires a value"
        OUT_ROOT="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done

  [[ -n "$LEVEL" ]] || { usage; die "Missing required --level"; }
  local phase
  if ! phase="$(level_to_phase "$LEVEL")"; then
    die "Invalid level: $LEVEL"
  fi

  local profile_rel
  profile_rel="$(level_to_profile_rel "$LEVEL")"
  local profile_path="$ROOT_DIR/$profile_rel"
  [[ -f "$profile_path" ]] || die "Missing profile: $profile_rel"

  require_cmd jq
  require_cmd tar

  mkdir -p "$OUT_ROOT"

  local package_name="ACP-certification-suite-${LEVEL}"
  local package_path="$OUT_ROOT/$package_name"
  local tarball_path="$OUT_ROOT/$package_name.tar.gz"

  [[ ! -e "$package_path" ]] || die "Output path already exists: $package_path"
  [[ ! -e "$tarball_path" ]] || die "Output path already exists: $tarball_path"

  local staging_root
  staging_root="$(mktemp -d "$OUT_ROOT/.stage.${package_name}.XXXXXX")"
  local staging_package="$staging_root/$package_name"
  STAGING_PACKAGE="$staging_package"
  mkdir -p "$staging_package"

  cleanup() {
    if [[ -n "${staging_root:-}" && -d "$staging_root" ]]; then
      rm -rf "$staging_root"
    fi
  }
  trap cleanup EXIT

  copy_dir "conformance" "conformance"
  copy_dir "schemas" "schemas"
  copy_dir "scripts" "scripts"
  copy_file "LICENSE" "LICENSE"
  copy_file "requirements-conformance.lock" "requirements-conformance.lock"
  if [[ -f "$ROOT_DIR/requirements-conformance.txt" ]]; then
    copy_file "requirements-conformance.txt" "requirements-conformance.txt"
  fi

  rm -rf "$staging_package/conformance/out"
  rm -rf "$staging_package/scripts/__pycache__"
  find "$staging_package" -type f -name '.DS_Store' -exec rm -f {} +

  local profile_id vector_manifest_rel valid_count invalid_count case_count schema_count generated_at has_requirements_txt
  profile_id="$(jq -r '.profile_id' "$profile_path")"
  vector_manifest_rel="$(jq -r '.vector_manifest // empty' "$profile_path")"
  valid_count="$(jq '.vectors.valid | length' "$profile_path")"
  invalid_count="$(jq '.vectors.invalid | length' "$profile_path")"
  case_count="$(jq '.cases | length' "$profile_path")"
  schema_count="$(jq '.schema_map | length' "$profile_path")"
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  has_requirements_txt="false"
  if [[ -f "$ROOT_DIR/requirements-conformance.txt" ]]; then
    has_requirements_txt="true"
  fi

  write_package_readme "$profile_rel" "$profile_id" "$phase" "$vector_manifest_rel" "$valid_count" "$invalid_count" "$case_count" "$schema_count" "$generated_at"
  write_manifest "$profile_rel" "$profile_id" "$phase" "$vector_manifest_rel" "$valid_count" "$invalid_count" "$case_count" "$schema_count" "$generated_at" "$has_requirements_txt"

  mv "$staging_package" "$package_path"
  tar -czf "$tarball_path" -C "$OUT_ROOT" "$package_name"

  cleanup
  trap - EXIT

  echo "export: wrote $package_path"
  echo "export: wrote $tarball_path"
  echo "export: level=$LEVEL phase=$phase profile=$profile_id"
}

main "$@"
