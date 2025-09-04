#!/usr/bin/env sh
set -eu
TEMPLATE_DIR="/etc/nginx/templates"
OUT_DIR="/etc/nginx/conf.d"
: "${FKS_DOMAIN_TEST:=fkstrading.test}"
: "${FKS_DOMAIN_PROD:=fkstrading.xyz}"

# Render each *.template -> *.conf
for tpl in "$TEMPLATE_DIR"/*.template; do
  [ -f "$tpl" ] || continue
  base=$(basename "$tpl" .template)
  out="$OUT_DIR/$base.conf"
  echo "[entrypoint] rendering $tpl -> $out"
  envsubst < "$tpl" > "$out"
  # Basic syntax check for each generated file
  if ! nginx -t >/dev/null 2>&1; then
    echo "[entrypoint][warn] nginx -t failed after including $out" >&2
  fi
done

echo "[entrypoint] final nginx config:" >&2
ls -1 "$OUT_DIR" >&2 || true

exec nginx -g 'daemon off;'
