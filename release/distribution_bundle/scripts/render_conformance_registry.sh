#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY_JSON="${1:-$ROOT_DIR/docs/registry/implementations.json}"
OUT_HTML="${2:-$ROOT_DIR/docs/registry/index.html}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

main() {
  require_cmd jq

  [[ -f "$REGISTRY_JSON" ]] || {
    echo "Missing registry file: $REGISTRY_JSON" >&2
    exit 1
  }

  jq -e '
    .version == 1 and
    (.generated_at | type == "string") and
    (.entries | type == "array") and
    (all(.entries[];
      (.implementation_id|type=="string") and
      (.name|type=="string") and
      (.maintainer|type=="string") and
      (.certification_level|test("^L[1-3]$")) and
      (.status as $s | (["active","revoked","suspended","expired"] | index($s)) != null) and
      (.self_authored|type=="boolean") and
      (.evidence.report_url|type=="string") and
      (.evidence.suite_manifest_url|type=="string") and
      (.issued_at|type=="string") and
      (.renewal_due|type=="string")
    ))
  ' "$REGISTRY_JSON" >/dev/null

  local rows
  rows="$(
    jq -r '
      .entries
      | sort_by(.name)
      | map(
          "<tr><td><code>" + .implementation_id + "</code></td>" +
          "<td>" + .name + "</td>" +
          "<td>" + .maintainer + "</td>" +
          "<td>" + .certification_level + "</td>" +
          "<td>" + .status + "</td>" +
          "<td>" + (if .self_authored then "yes" else "no" end) + "</td>" +
          "<td>" + .issued_at + "</td>" +
          "<td>" + .renewal_due + "</td>" +
          "<td><a href=\"" + .evidence.report_url + "\">report</a></td>" +
          "<td><a href=\"" + .evidence.suite_manifest_url + "\">suite manifest</a></td></tr>"
        )
      | join("\n")
    ' "$REGISTRY_JSON"
  )"

  local total active external_active generated
  total="$(jq -r '.entries | length' "$REGISTRY_JSON")"
  active="$(jq -r '[.entries[] | select(.status=="active")] | length' "$REGISTRY_JSON")"
  external_active="$(jq -r '[.entries[] | select(.status=="active" and .self_authored==false)] | length' "$REGISTRY_JSON")"
  generated="$(jq -r '.generated_at' "$REGISTRY_JSON")"

  mkdir -p "$(dirname "$OUT_HTML")"
  cat >"$OUT_HTML" <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>ACP Conformant Implementation Registry</title>
  <style>
    :root {
      --bg: #f7f5ef;
      --ink: #1f2a37;
      --line: #d2c9b8;
      --accent: #1a6b5a;
      --card: #fffdf8;
    }
    * { box-sizing: border-box; }
    body { margin: 0; font-family: "IBM Plex Sans", "Noto Sans", sans-serif; color: var(--ink); background: linear-gradient(120deg, #f7f5ef, #ece6d9); }
    main { max-width: 1100px; margin: 0 auto; padding: 28px 20px 56px; }
    h1 { margin: 0 0 8px; font-size: 30px; }
    p { margin: 6px 0; }
    .meta { color: #4a5565; font-size: 14px; }
    .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin: 16px 0 20px; }
    .card { background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 12px; }
    .card .k { font-size: 12px; color: #5a6575; text-transform: uppercase; letter-spacing: .05em; }
    .card .v { margin-top: 4px; font-size: 28px; font-weight: 700; color: var(--accent); }
    .table-wrap { overflow: auto; background: var(--card); border: 1px solid var(--line); border-radius: 10px; }
    table { width: 100%; border-collapse: collapse; min-width: 940px; }
    th, td { padding: 10px; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; font-size: 14px; }
    th { background: #f0eadc; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <main>
    <h1>ACP Conformant Implementation Registry</h1>
    <p class="meta">Machine-readable source: <code>docs/registry/implementations.json</code></p>
    <p class="meta">Generated at: $generated</p>
    <div class="cards">
      <div class="card"><div class="k">Total Entries</div><div class="v">$total</div></div>
      <div class="card"><div class="k">Active Entries</div><div class="v">$active</div></div>
      <div class="card"><div class="k">External Active</div><div class="v">$external_active</div></div>
    </div>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Implementation ID</th>
            <th>Name</th>
            <th>Maintainer</th>
            <th>Level</th>
            <th>Status</th>
            <th>Self-authored</th>
            <th>Issued</th>
            <th>Renewal Due</th>
            <th>Evidence Report</th>
            <th>Suite Manifest</th>
          </tr>
        </thead>
        <tbody>
$rows
        </tbody>
      </table>
    </div>
  </main>
</body>
</html>
HTML

  echo "registry-site: ok ($OUT_HTML)"
}

main "$@"
