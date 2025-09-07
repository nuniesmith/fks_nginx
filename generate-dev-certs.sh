#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dev_certs"
mkdir -p "$DIR"
CRT="$DIR/server.crt"
KEY="$DIR/server.key"
DH="$DIR/dhparam.pem"
if [[ -f "$CRT" && -f "$KEY" ]]; then
  echo "[dev-certs] existing certs present ($CRT)" >&2
else
  echo "[dev-certs] generating self-signed cert" >&2
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/C=US/ST=NA/L=Local/O=FKS/OU=Dev/CN=localhost" -keyout "$KEY" -out "$CRT" >/dev/null 2>&1
fi

# Provide duplicate names expected by alternate configs (selfsigned.*)
for base in selfsigned; do
  [[ -f "$DIR/${base}.crt" ]] || cp "$CRT" "$DIR/${base}.crt"
  [[ -f "$DIR/${base}.key" ]] || cp "$KEY" "$DIR/${base}.key"
done
if [[ ! -f "$DH" ]]; then
  echo "[dev-certs] generating dhparam (may take a while)" >&2
  openssl dhparam -out "$DH" 2048 >/dev/null 2>&1 || echo "[dev-certs] dhparam generation skipped"
fi
ls -l "$DIR" >&2
