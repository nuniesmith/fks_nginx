#!/bin/sh
set -e

# Inject dashboard token into environment if mounted
TOKEN_FILE="/etc/nginx/secrets/dashboard-token.txt"
if [ -f "$TOKEN_FILE" ]; then
  export DASHBOARD_TOKEN="$(cat "$TOKEN_FILE" | tr -d '\n' | tr -d '\r')"
  echo "[entrypoint] Loaded dashboard token (length: ${#DASHBOARD_TOKEN})"
else
  export DASHBOARD_TOKEN=""
  echo "[entrypoint] Warning: Dashboard token file not found: $TOKEN_FILE"
  echo "[entrypoint] k8s.fkstrading.xyz will return 503 until token is configured"
fi

# Use envsubst to substitute environment variables in config files
# This allows us to use ${DASHBOARD_TOKEN} in nginx config files
echo "[entrypoint] Processing nginx configuration files with envsubst..."

# Process k8s dashboard config if it exists
if [ -f /etc/nginx/conf.d/k8s.fkstrading.xyz.conf ]; then
  # Export DASHBOARD_TOKEN for envsubst (already exported above)
  # Use single quotes to prevent shell expansion, envsubst will handle ${VAR}
  envsubst '${DASHBOARD_TOKEN}' < /etc/nginx/conf.d/k8s.fkstrading.xyz.conf > /tmp/k8s.fkstrading.xyz.conf.tmp
  mv /tmp/k8s.fkstrading.xyz.conf.tmp /etc/nginx/conf.d/k8s.fkstrading.xyz.conf
  if [ -n "$DASHBOARD_TOKEN" ]; then
    echo "[entrypoint] Processed k8s.fkstrading.xyz.conf with token substitution (token length: ${#DASHBOARD_TOKEN})"
  else
    echo "[entrypoint] Warning: Processed k8s.fkstrading.xyz.conf but DASHBOARD_TOKEN is empty"
  fi
fi

# Test nginx configuration
echo "[entrypoint] Testing nginx configuration..."
nginx -t || {
  echo "[entrypoint] ERROR: Nginx configuration test failed!"
  exit 1
}

echo "[entrypoint] Starting nginx..."
exec nginx -g 'daemon off;'