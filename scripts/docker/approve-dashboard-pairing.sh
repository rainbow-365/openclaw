#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not on PATH." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose is not available." >&2
  exit 1
fi

TOKEN="$(docker compose exec -T openclaw-gateway printenv OPENCLAW_GATEWAY_TOKEN 2>/dev/null | tr -d '\r')"
if [[ -z "$TOKEN" ]]; then
  echo "ERROR: OPENCLAW_GATEWAY_TOKEN is not set in the openclaw-gateway container." >&2
  exit 1
fi

REQUEST_ID="${1:-}"

if [[ -n "$REQUEST_ID" ]]; then
  echo "Approving dashboard pairing request: $REQUEST_ID"
  docker compose exec -T openclaw-gateway \
    node dist/index.js devices approve "$REQUEST_ID" \
    --url ws://127.0.0.1:18789 \
    --token "$TOKEN" \
    --json
else
  echo "Approving latest pending dashboard pairing request..."
  docker compose exec -T openclaw-gateway \
    node dist/index.js devices approve --latest \
    --url ws://127.0.0.1:18789 \
    --token "$TOKEN" \
    --json
fi

echo
echo "Done. Refresh the dashboard browser tab."
