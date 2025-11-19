#!/bin/sh
set -e

# Inject dashboard token into environment if mounted
TOKEN_FILE="/etc/nginx/secrets/dashboard-token.txt"
if [ -f "$TOKEN_FILE" ]; then
  export DASHBOARD_TOKEN="$(cat "$TOKEN_FILE" | tr -d '\n' | tr -d '\r')"
  echo "[entrypoint] Loaded dashboard token (length: ${#DASHBOARD_TOKEN})"
else
  echo "[entrypoint] Dashboard token file not found: $TOKEN_FILE"
fi

exec nginx -g 'daemon off;'