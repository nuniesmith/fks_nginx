# Nginx Reverse Proxy for FKS Trading Platform
FROM nginx:1.25-alpine

# Install gettext for envsubst (environment variable substitution)
RUN apk add --no-cache gettext

# Remove default nginx config
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create directories for SSL certificates and logs
RUN mkdir -p /etc/nginx/ssl \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/www/html \
    && mkdir -p /var/www/certbot

# Copy SSL certificates if they exist (optional - can be mounted as volume)
# COPY ssl/ /etc/nginx/ssl/

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider --timeout=3 --no-check-certificate https://localhost/health 2>/dev/null || exit 1

# Start via entrypoint to inject dashboard token if mounted
ENTRYPOINT ["/entrypoint.sh"]

