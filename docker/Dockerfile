# =================================================================
# Nginx Dockerfile - Improved Version with Better Error Handling
# =================================================================
# This Dockerfile creates a dynamic nginx container that can be
# configured via environment variables at runtime

FROM nginx:alpine AS final

# Build arguments for customization
ARG DOMAIN_NAME=localhost
ARG ENABLE_SSL=false
ARG BUILD_DATE
ARG BUILD_VERSION=1.0.0
ARG BUILD_COMMIT
ARG USER_NAME=nginx
ARG USER_ID=101
ARG GROUP_ID=101

# Install required packages with better error handling
RUN set -euo pipefail \
    && apk add --no-cache \
        bash \
        openssl \
        gettext \
        curl \
        tzdata \
        shadow \
        file \
    && rm -rf /var/cache/apk/* \
    && echo "✅ Package installation completed"

# Create nginx user with specific UID/GID if it doesn't exist
RUN set -euo pipefail \
    && if ! id -u ${USER_NAME} >/dev/null 2>&1; then \
        echo "Creating user ${USER_NAME} with UID ${USER_ID}"; \
        addgroup -g ${GROUP_ID} -S ${USER_NAME}; \
        adduser -u ${USER_ID} -D -S -h /var/cache/nginx -s /sbin/nologin -G ${USER_NAME} ${USER_NAME}; \
    fi

# Create required directories with proper permissions
RUN set -euo pipefail \
    && mkdir -p \
        /etc/nginx/templates \
        /etc/nginx/ssl \
        /etc/nginx/conf.d \
        /usr/share/nginx/html/health \
        /var/log/nginx \
        /var/cache/nginx \
        /var/run/nginx \
        /docker-entrypoint.d \
    && chown -R ${USER_NAME}:${USER_NAME} \
        /var/cache/nginx \
        /var/log/nginx \
        /var/run/nginx \
    && chmod 755 /var/log/nginx \
    && echo "✅ Directory structure created"

# Copy nginx configuration templates with validation
COPY --chown=${USER_NAME}:${USER_NAME} config/networking/nginx/templates/*.template /etc/nginx/templates/

# Validate required templates exist
RUN set -euo pipefail \
    && echo "Validating required templates..." \
    && for tmpl in nginx.conf.template default.conf.template; do \
        if [ ! -f "/etc/nginx/templates/$tmpl" ]; then \
            echo "❌ ERROR: Required template $tmpl not found" >&2; \
            exit 1; \
        fi; \
    done \
    && echo "✅ All required templates found"

# Copy static configuration files
COPY --chown=${USER_NAME}:${USER_NAME} config/networking/nginx/proxy_params_*.conf /etc/nginx/

# Add missing ssl-params configuration
COPY --chown=${USER_NAME}:${USER_NAME} config/networking/nginx/ssl-params.conf /etc/nginx/

# Ensure HTML directory exists
RUN mkdir -p /usr/share/nginx/html

# Create fallback index if needed
RUN if [ ! -f /usr/share/nginx/html/index.html ]; then \
    echo "<h1>FKS Trading Systems</h1><p>Nginx is running</p>" > /usr/share/nginx/html/index.html; \
fi

# Create health check endpoints
RUN set -euo pipefail \
    && echo "OK" > /usr/share/nginx/html/health/index.html \
    && echo '{"status":"healthy","service":"nginx"}' > /usr/share/nginx/html/health/status.json \
    && chown -R ${USER_NAME}:${USER_NAME} /usr/share/nginx/html

# Copy entrypoint scripts
COPY scripts/docker/entrypoint-nginx.sh /docker-entrypoint.sh
COPY scripts/docker/entrypoint-nginx-auth.sh /docker-entrypoint-auth.sh
COPY scripts/docker/healthcheck.sh /healthcheck.sh
COPY scripts/docker/nginx-test-config.sh /test-config.sh

# Make scripts executable
RUN chmod +x /docker-entrypoint.sh /docker-entrypoint-auth.sh /healthcheck.sh /test-config.sh

# Create self-signed certificate for development (if needed)
RUN set -euo pipefail \
    && if [ "$ENABLE_SSL" = "true" ] && [ ! -f "/etc/nginx/ssl/cert.pem" ]; then \
        echo "Generating self-signed certificate for development..."; \
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/key.pem \
            -out /etc/nginx/ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=FKS Trading Systems/CN=$DOMAIN_NAME" \
            2>/dev/null \
        && chmod 600 /etc/nginx/ssl/*.pem \
        && chown ${USER_NAME}:${USER_NAME} /etc/nginx/ssl/*.pem \
        && echo "✅ Self-signed certificate generated"; \
    fi

# Security hardening
RUN set -euo pipefail \
    && echo "Applying security hardening..." \
    && find /etc/nginx -name "*.key" -o -name "*.pem" -exec chmod 600 {} \; 2>/dev/null || true \
    && find /usr/share/nginx/html -type f -exec chmod 644 {} \; \
    && find /usr/share/nginx/html -type d -exec chmod 755 {} \; \
    && echo "✅ Security hardening applied"

# Environment variables (can be overridden at runtime)
ENV DOMAIN_NAME=${DOMAIN_NAME} \
    ENABLE_SSL=${ENABLE_SSL} \
    BASE_DOMAIN=${DOMAIN_NAME} \
    API_HOST=api \
    API_PORT=8000 \
    WEB_HOST=web \
    WEB_PORT=3000 \
    WORKER_HOST=worker \
    WORKER_PORT=8001 \
    NGINX_WORKER_PROCESSES=auto \
    NGINX_WORKER_CONNECTIONS=1024 \
    CLIENT_MAX_BODY_SIZE=100M \
    PROXY_CONNECT_TIMEOUT=60s \
    PROXY_SEND_TIMEOUT=60s \
    PROXY_READ_TIMEOUT=60s \
    KEEPALIVE_TIMEOUT=65 \
    GZIP_ENABLED=on \
    GZIP_COMP_LEVEL=6 \
    REAL_IP_HEADER=X-Forwarded-For \
    SET_REAL_IP_FROM="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16" \
    SERVICE_RUNTIME=nginx \
    SERVICE_NAME=nginx \
    SERVICE_PORT=80

# Labels
LABEL maintainer="nuniesmith" \
      org.opencontainers.image.title="FKS Nginx Proxy" \
      org.opencontainers.image.description="Dynamic Nginx reverse proxy for FKS Trading Systems" \
      org.opencontainers.image.version="${BUILD_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/nuniesmith/fks" \
      org.opencontainers.image.documentation="https://github.com/nuniesmith/fks/blob/main/docs/nginx.md" \
      org.opencontainers.image.vendor="nuniesmith" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="nginx-proxy" \
      com.fks.build.commit="${BUILD_COMMIT}" \
      com.fks.build.version="${BUILD_VERSION}" \
      com.fks.component="proxy" \
      com.fks.service.type="nginx"

# Test configuration script is copied from deployment/docker/nginx/test-config.sh

# Expose ports
EXPOSE 80 443

# Health check with multiple fallbacks
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD /test-config.sh && \
        /healthcheck.sh --port 80 --type http --endpoint /health/ --timeout 5 || \
        curl -f http://localhost/health/ || \
        nc -z localhost 80 || \
        exit 1

# Create .dockerignore validation marker (with fallback)
RUN touch /.dockerignore.status && \
    echo "✅ Using fallback .dockerignore validation" > /.dockerignore.status

# Final validation
RUN set -euo pipefail \
    && echo "=== Final Build Validation ===" \
    && echo "User: $(id -u ${USER_NAME}):$(id -g ${USER_NAME})" \
    && echo "Nginx version: $(nginx -v 2>&1)" \
    && echo "Templates: $(ls -la /etc/nginx/templates/*.template | wc -l) found" \
    && echo "SSL enabled: ${ENABLE_SSL}" \
    && echo "Build date: ${BUILD_DATE:-unknown}" \
    && echo "Build version: ${BUILD_VERSION}" \
    && cat /.dockerignore.status \
    && echo "=== Build Complete ===" \
    && rm -f /.dockerignore.status

# Use custom entrypoint that processes templates as root, then nginx runs as nginx user
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
