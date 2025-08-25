###################################################################################################
# Thin Wrapper Dockerfile for fks_nginx
# -----------------------------------------------------------------------------------------------
# This image now DELEGATES to the canonical shared nginx implementation under `shared/shared_nginx`.
# Goal: eliminate duplicated build logic and keep all hardening / config in one maintained location.
#
# Usage Patterns:
# 1. (Recommended) Build the shared image once, then build this wrapper:
#      docker build -t shared-nginx:latest shared/shared_nginx
#      docker build -t fks_nginx:latest \
#         --build-arg SHARED_NGINX_IMAGE=shared-nginx:latest fks/fks_nginx/docker
# 2. (CI) Point SHARED_NGINX_IMAGE to a remote registry tag (e.g. ghcr.io/ORG/shared-nginx:TAG).
# 3. (Override) Copy minimal conf overrides into /etc/nginx/... via an additional COPY here.
#
# If you still need legacy dynamic template behaviour from the removed custom Dockerfile, migrate the
# relevant scripts/templates upstream into `shared/shared_nginx` so all consumers benefit.
###################################################################################################

# Build arg allowing selection of the pre-built shared nginx base image.
ARG SHARED_NGINX_IMAGE=shared-nginx:latest

# IMPORTANT: ARG must appear before FROM when used in FROM.
FROM ${SHARED_NGINX_IMAGE} AS runtime

LABEL com.fks.component="proxy" \
    com.fks.image.wrapper="true" \
    com.fks.wrapper.delegates="shared/shared_nginx" \
    org.opencontainers.image.description="FKS nginx wrapper delegating to shared/shared_nginx"

# (Optional) Place for FKS-specific overrides. Keep minimal. Examples shown commented out.
# COPY config/overrides/conf.d/*.conf /etc/nginx/conf.d/
# COPY html/ /usr/share/nginx/html/

# Simple smoke marker to confirm wrapper layer present.
RUN echo "fks_nginx wrapper layer active" > /fks_nginx_wrapper.info

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD /healthcheck.sh || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
