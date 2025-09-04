#!/usr/bin/env bash
set -euo pipefail

# generate-san-cert.sh
# Generates a SAN self-signed certificate for local/dev usage covering test + prod domains & subdomains.
# Output: ssl_certs/dev-san.key, ssl_certs/dev-san.crt (unless overridden)
# Usage:
#   FKS_DOMAIN_TEST=fkstrading.test FKS_DOMAIN_PROD=fkstrading.xyz ./scripts/generate-san-cert.sh
#   CERT_DAYS=825 ./scripts/generate-san-cert.sh

DOMAIN_TEST=${FKS_DOMAIN_TEST:-fkstrading.test}
DOMAIN_PROD=${FKS_DOMAIN_PROD:-fkstrading.xyz}
OUT_DIR=${CERT_OUT_DIR:-ssl_certs}
KEY=${CERT_KEY_NAME:-dev-san.key}
CRT=${CERT_CRT_NAME:-dev-san.crt}
DAYS=${CERT_DAYS:-365}

mkdir -p "$OUT_DIR"
CFG=$(mktemp)
cat >"$CFG" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = ${DOMAIN_TEST}

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = ${DOMAIN_TEST}
DNS.2 = www.${DOMAIN_TEST}
DNS.3 = api.${DOMAIN_TEST}
DNS.4 = data.${DOMAIN_TEST}
DNS.5 = auth.${DOMAIN_TEST}
DNS.6 = ${DOMAIN_PROD}
DNS.7 = www.${DOMAIN_PROD}
DNS.8 = api.${DOMAIN_PROD}
DNS.9 = data.${DOMAIN_PROD}
DNS.10 = auth.${DOMAIN_PROD}
EOF

echo "[*] Generating SAN cert for ${DOMAIN_TEST}, ${DOMAIN_PROD} -> ${OUT_DIR}/${CRT}" >&2
openssl req -x509 -nodes -newkey rsa:2048 -days "$DAYS" \
  -keyout "${OUT_DIR}/${KEY}" -out "${OUT_DIR}/${CRT}" -config "$CFG" -extensions v3_req
chmod 600 "${OUT_DIR}/${KEY}" "${OUT_DIR}/${CRT}"
rm -f "$CFG"

echo "[+] Done. To use inside container, mount or copy as /etc/nginx/certs/selfsigned.key/.crt" >&2
