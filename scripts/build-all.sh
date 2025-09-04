#!/usr/bin/env bash
set -euo pipefail

# Builds the shared base nginx image then the fks_nginx image.
# Usage: ./scripts/build-all.sh [VERSION]

VERSION="${1:-1.27.1}"
BASE_TAG="shared/nginx:${VERSION}-alpine"

pushd "$(dirname "$0")/.." >/dev/null

if ! docker image inspect "$BASE_TAG" >/dev/null 2>&1; then
  echo "[build] Building base image $BASE_TAG"
  docker build \
    --build-arg VERSION="$VERSION" \
    -t "$BASE_TAG" \
    ./shared/shared_nginx
else
  echo "[build] Base image $BASE_TAG already exists (skipping)"
fi

echo "[build] Building fks_nginx (depends on $BASE_TAG)"
docker compose build fks_nginx

echo "[build] Done. Images:"
docker images | grep -E "(shared/nginx|fks_nginx)" || true

popd >/dev/null
