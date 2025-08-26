# Dockerfile Options

This service supports two build strategies:

1. Simplified: 
   docker build -f Dockerfile.simple -t fks_nginx:simple .

2. Unified (full multi-runtime + GPU support) shared file:
   docker build -f ../../shared/shared_docker/Dockerfile -t fks_nginx:unified      --build-arg SERVICE_RUNTIME=nginx .

Default repository Dockerfile may still be the unified version; adopt the simple one by renaming if desired.
