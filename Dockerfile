# Multi-stage Dockerfile extending shared Nginx template

# Extends shared Nginx template
FROM shared/nginx:1.27.1-alpine AS final

# Copy custom nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d/ /etc/nginx/conf.d/

# Copy SSL certificates and static content if they exist
# Copy SSL certificates (self-signed dev bundle expected to contain SANs for all local domains)
# Using /etc/nginx/certs to align with existing fallback default.conf references
COPY ssl_certs /etc/nginx/ssl/
COPY html /usr/share/nginx/html/

# Dev fallback: generate self-signed cert if expected /etc/nginx/ssl/server.crt missing
USER root
RUN mkdir -p /etc/nginx/ssl && \
    if [ ! -f /etc/nginx/ssl/server.crt ]; then \
      echo "[dev-ssl] generating self-signed certificate" && \
      apk add --no-cache openssl >/dev/null 2>&1 || true && \
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=US/ST=NA/L=Local/O=FKS/OU=Dev/CN=localhost" >/dev/null 2>&1 || true; \
    fi
USER nginx

# Set service-specific environment variables
ENV SERVICE_NAME=fks-nginx \
    SERVICE_TYPE=nginx \
    SERVICE_PORT=80 \
    NGINX_WORKER_PROCESSES=auto \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_KEEPALIVE_TIMEOUT=65

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE ${SERVICE_PORT}

# Use nginx user from base image
USER nginx

# Use nginx as the entrypoint
CMD ["nginx", "-g", "daemon off;"]
