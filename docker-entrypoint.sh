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

# Optional: wait briefly for core upstream DNS names to appear on the docker network
WAIT_HOSTS="fks_api fks_web fks_data fks_auth"
for h in $WAIT_HOSTS; do
  for i in 1 2 3 4 5; do
    if getent hosts "$h" >/dev/null 2>&1; then
      echo "[entrypoint] resolved $h"; break
    fi
    echo "[entrypoint] waiting for $h (attempt $i)"; sleep 1
  done
done

# Final syntax test (will now include any dynamically generated conf)
nginx -t || echo "[entrypoint][warn] final nginx -t reported errors; continuing so container can retry/reload" >&2

exec nginx -g 'daemon off;'
