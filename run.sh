#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[nginx] Stopping existing containers..."
docker compose down

echo "[nginx] Rebuilding images..."
docker compose build

echo "[nginx] Starting containers in detached mode..."
docker compose up -d
