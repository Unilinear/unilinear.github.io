#!/usr/bin/env bash
# Refresh globe visitor data from GoatCounter API.
# Usage: GOATCOUNTER_TOKEN=your_token GOATCOUNTER_SITE=yoursite ./update-globe.sh
#
# Requires: curl, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTFILE="$SCRIPT_DIR/globe-data.json"

if [[ -z "${GOATCOUNTER_TOKEN:-}" || -z "${GOATCOUNTER_SITE:-}" ]]; then
  echo "::warning::GOATCOUNTER_TOKEN or GOATCOUNTER_SITE is not configured; keeping existing $OUTFILE." >&2
  exit 0
fi

site_host="${GOATCOUNTER_SITE}"
site_host="${site_host#http://}"
site_host="${site_host#https://}"
site_host="${site_host%%/*}"
site_host="${site_host%.}"
site_host="${site_host//[[:space:]]/}"

if [[ -z "$site_host" ]]; then
  echo "::error::GOATCOUNTER_SITE did not contain a usable site name or host." >&2
  exit 1
fi

if [[ "$site_host" != *.* ]]; then
  site_host="${site_host}.goatcounter.com"
fi

API_URL="https://${site_host}/api/v0/stats/locations?limit=100"
response_file="$(mktemp)"
output_file="$(mktemp)"

cleanup() {
  rm -f "$response_file" "$output_file"
}
trap cleanup EXIT

if ! http_status="$(curl -sS -o "$response_file" -w "%{http_code}" -H "Authorization: Bearer $GOATCOUNTER_TOKEN" "$API_URL")"; then
  echo "::error::Unable to reach GoatCounter API at https://${site_host}/api/v0/stats/locations." >&2
  exit 1
fi

if [[ "$http_status" -lt 200 || "$http_status" -ge 300 ]]; then
  error_message="$(jq -r 'if .error then .error elif .Error then .Error elif .errors then (.errors | tostring) else empty end' "$response_file" 2>/dev/null || true)"
  echo "::error::GoatCounter API returned HTTP $http_status${error_message:+: $error_message}" >&2
  exit 1
fi

if ! jq -e '{
  period: "all time",
  updated: (now | strftime("%Y-%m-%d")),
  total_visitors: ([.stats[]?.count] | add // 0),
  locations: (
    [.stats[]?
      | {
          country: (.id | tostring | split("-")[0] | ascii_upcase),
          count: (.count // 0)
        }
      | select(.country | test("^[A-Z]{2}$"))
    ]
    | group_by(.country)
    | map({country: .[0].country, count: (map(.count) | add)})
    | sort_by(.count)
    | reverse
  )
}' "$response_file" > "$output_file"; then
  echo "::error::GoatCounter API response did not match the expected stats format." >&2
  exit 1
fi

mv "$output_file" "$OUTFILE"

echo "Updated $OUTFILE with $(jq '(.locations // []) | length' "$OUTFILE") locations."
