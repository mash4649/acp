#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/conformance/out/security"
REQ_FILE="$ROOT_DIR/requirements-conformance.lock"

if [[ ! -f "$REQ_FILE" ]]; then
  REQ_FILE="$ROOT_DIR/requirements-conformance.txt"
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

doctor() {
  require_cmd python3
  require_cmd shasum
  [[ -f "$REQ_FILE" ]] || { echo "Missing requirements file: $REQ_FILE" >&2; exit 1; }
  mkdir -p "$OUT_DIR"
  echo "doctor: ok"
}

generate_lock_fingerprint() {
  local out="$OUT_DIR/requirements-conformance.sha256"
  shasum -a 256 "$REQ_FILE" | awk '{print $1}' >"$out"
  echo "lock-fingerprint: wrote $out"
}

generate_sbom_min() {
  local out="$OUT_DIR/sbom-min.json"
  python3 - "$REQ_FILE" "$out" <<'PY'
import json
import platform
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

req_file = Path(sys.argv[1])
out_file = Path(sys.argv[2])

components = []
for raw in req_file.read_text(encoding="utf-8").splitlines():
    line = raw.strip()
    if not line or line.startswith("#"):
        continue
    m = re.match(r"^([A-Za-z0-9_.-]+)==([A-Za-z0-9_.!+\-]+)$", line)
    if m:
        name, version = m.group(1), m.group(2)
    else:
        name, version = line, None
    components.append(
        {
            "type": "library",
            "name": name,
            "version": version,
            "purl": f"pkg:pypi/{name}" + (f"@{version}" if version else ""),
        }
    )

doc = {
    "sbom_type": "acp-minimum-sbom-v1",
    "generated_at_utc": datetime.now(timezone.utc).isoformat(),
    "source": str(req_file.name),
    "tool": "scripts/security_ops_minimum.sh",
    "environment": {
        "python_version": platform.python_version(),
        "platform": platform.platform(),
    },
    "components": components,
}

out_file.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
  echo "sbom-min: wrote $out"
}

run_vuln_scan() {
  local out="$OUT_DIR/vuln-scan.txt"
  if command -v pip-audit >/dev/null 2>&1; then
    if pip-audit -r "$REQ_FILE" --no-deps --disable-pip >"$out" 2>&1; then
      echo "vuln-scan: no known vulnerabilities (pip-audit)"
      return 0
    fi
    echo "vuln-scan: vulnerabilities detected (see $out)" >&2
    return 1
  fi

  if command -v uv >/dev/null 2>&1; then
    if uvx --from pip-audit pip-audit -r "$REQ_FILE" --no-deps --disable-pip >"$out" 2>&1; then
      echo "vuln-scan: no known vulnerabilities (uvx pip-audit)"
      return 0
    fi
    echo "vuln-scan: vulnerabilities detected (see $out)" >&2
    return 1
  fi

  {
    echo "No vulnerability scanner available."
    echo "Preferred: uvx --from pip-audit pip-audit -r $(basename "$REQ_FILE")"
    echo "Alternative install: python3 -m pip install pip-audit"
    echo "Then run: ./scripts/security_ops_minimum.sh vuln"
  } >"$out"
  echo "vuln-scan: skipped (pip-audit/uv unavailable), wrote $out"
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts/security_ops_minimum.sh doctor
  ./scripts/security_ops_minimum.sh lock
  ./scripts/security_ops_minimum.sh sbom
  ./scripts/security_ops_minimum.sh vuln
  ./scripts/security_ops_minimum.sh all

Outputs:
  conformance/out/security/requirements-conformance.sha256
  conformance/out/security/sbom-min.json
  conformance/out/security/vuln-scan.txt
EOF
}

main() {
  local cmd="${1:-all}"
  doctor

  case "$cmd" in
    doctor)
      ;;
    lock)
      generate_lock_fingerprint
      ;;
    sbom)
      generate_sbom_min
      ;;
    vuln)
      run_vuln_scan
      ;;
    all)
      generate_lock_fingerprint
      generate_sbom_min
      run_vuln_scan
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
