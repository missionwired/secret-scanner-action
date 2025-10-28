#!/usr/bin/env bash
set -euo pipefail

jq_bin="${JQ_BIN:-jq}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFORM="${SCRIPT_DIR}/detect-secrets-to-sarif.jq"

if [[ ! -f "${TRANSFORM}" ]]; then
  echo "Transform script not found: ${TRANSFORM}" >&2
  exit 1
fi

pass=true

echo "== Test 1: Empty results =="
cat > empty.json <<'EOF'
{
  "results": {}
}
EOF
"${jq_bin}" -f "${TRANSFORM}" empty.json > empty.sarif || { echo "jq transform failed on empty"; pass=false; }
RAW_COUNT=$(jq -r '[ (.results? // {}) | to_entries[]? | (.value | length) ] | add // 0' empty.json)
SARIF_COUNT=$(jq -r '[ .runs[]? | ( .results? // [] ) | length ] | add // 0' empty.sarif)
printf 'Raw Count: %s\nSARIF Count: %s\n' "$RAW_COUNT" "$SARIF_COUNT"
[[ "$RAW_COUNT" == 0 && "$SARIF_COUNT" == 0 ]] || { echo "FAILED zero-count assertion"; pass=false; }
RULES_LEN=$(jq -r '.runs[0].tool.driver.rules | length' empty.sarif)
[[ "$RULES_LEN" == 0 ]] || { echo "FAILED rules length 0 assertion (got $RULES_LEN)"; pass=false; }

echo "== Test 2: Single finding =="
cat > single.json <<'EOF'
{
  "results": {
    "app/uploads.js": [
      {
        "type": "AWS Access Key",
        "line_number": 12,
        "hashed_secret": "abcdef123456",
        "is_verified": false
      }
    ]
  }
}
EOF
"${jq_bin}" -f "${TRANSFORM}" single.json > single.sarif || { echo "jq transform failed on single"; pass=false; }
RAW_COUNT=$(jq -r '[ (.results? // {}) | to_entries[]? | (.value | length) ] | add // 0' single.json)
SARIF_COUNT=$(jq -r '[ .runs[]? | ( .results? // [] ) | length ] | add // 0' single.sarif)
printf 'Raw Count: %s\nSARIF Count: %s\n' "$RAW_COUNT" "$SARIF_COUNT"
[[ "$RAW_COUNT" == 1 && "$SARIF_COUNT" == 1 ]] || { echo "FAILED single-count assertion"; pass=false; }
RULES_LEN=$(jq -r '.runs[0].tool.driver.rules | length' single.sarif)
[[ "$RULES_LEN" -ge 1 ]] || { echo "FAILED rules length >=1 assertion (got $RULES_LEN)"; pass=false; }
MESSAGE=$(jq -r '.runs[0].results[0].message.text' single.sarif)
[[ "$MESSAGE" == *"AWS Access Key"* ]] || { echo "FAILED message contains type"; pass=false; }

echo "== Test 3: Multiple findings (two files) =="
cat > multi.json <<'EOF'
{
  "results": {
    "app/uploads.js": [
      { "type": "AWS Access Key", "line_number": 12, "hashed_secret": "abcdef123456", "is_verified": false },
      { "type": "GitHub Token", "line_number": 42, "hashed_secret": "deadbeefcafefe", "is_verified": true }
    ],
    "config/settings.py": [
      { "type": "Private Key", "line_number": 7, "hashed_secret": "0102030405", "is_verified": false }
    ]
  }
}
EOF
"${jq_bin}" -f "${TRANSFORM}" multi.json > multi.sarif || { echo "jq transform failed on multi"; pass=false; }
RAW_COUNT=$(jq -r '[ (.results? // {}) | to_entries[]? | (.value | length) ] | add // 0' multi.json)
SARIF_COUNT=$(jq -r '[ .runs[]? | ( .results? // [] ) | length ] | add // 0' multi.sarif)
printf 'Raw Count: %s\nSARIF Count: %s\n' "$RAW_COUNT" "$SARIF_COUNT"
[[ "$RAW_COUNT" == 3 && "$SARIF_COUNT" == 3 ]] || { echo "FAILED multi-count assertion"; pass=false; }
RULES_LEN=$(jq -r '.runs[0].tool.driver.rules | length' multi.sarif)
[[ "$RULES_LEN" -ge 3 ]] || { echo "FAILED rules length >=3 assertion (got $RULES_LEN)"; pass=false; }
FIRST_MSG=$(jq -r '.runs[0].results[0].message.text' multi.sarif)
[[ "$FIRST_MSG" == *"detected in"* ]] || { echo "FAILED multi message format"; pass=false; }

rm -f empty.json empty.sarif single.json single.sarif
rm -f multi.json multi.sarif

if [[ "$pass" == true ]]; then
  echo "All tests passed"
else
  echo "One or more tests failed" >&2
  exit 1
fi
