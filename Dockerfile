# Multi-stage Dockerfile extending shared Nginx template

# Extends shared Nginx template
FROM shared/nginx:1.27.1-alpine AS final

# Copy custom nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d/ /etc/nginx/conf.d/

# Copy SSL certificates if they exist
COPY ssl /etc/nginx/ssl/ 

# Copy static content if it exists  
COPY html /usr/share/nginx/html/

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

# Use template's nginx user
USER appuser

# Use nginx as the entrypoint
CMD ["nginx", "-g", "daemon off;"]
