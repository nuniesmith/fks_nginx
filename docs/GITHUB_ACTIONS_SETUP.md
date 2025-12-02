# GitHub Actions Setup for Nginx Service

**Status:** ✅ Configured and Ready

---

## Workflow File

**Location:** `.github/workflows/docker-build-push.yml`

## What It Does

### 1. Validate Job
- ✅ Validates nginx configuration files
- ✅ Ensures `nginx.conf` and `conf.d/*.conf` are syntactically correct
- ✅ Uses nginx:alpine to test configuration
- ✅ Fails build if configuration is invalid

### 2. Build and Push Job
- ✅ Builds Docker image from `Dockerfile`
- ✅ Pushes to Docker Hub: `nuniesmith/fks:nginx-latest`
- ✅ Creates multiple tags:
  - `nginx-latest` (main/master branch)
  - `nginx-<sha>` (commit SHA)
  - `nginx-<branch>` (branch name)
  - `nginx-<version>` (semantic version tags)

---

## Triggers

The workflow runs on:
- ✅ Push to `main`, `master`, or `develop` branches
- ✅ Push of version tags (`v*`)
- ✅ Pull requests to `main` or `master`

**Note:** Only pushes to `main`/`master` or version tags will build and push images.

---

## Docker Image

**Repository:** `nuniesmith/fks`  
**Image:** `nuniesmith/fks:nginx-latest`  
**Base Image:** `nginx:1.25-alpine`

---

## Secrets Required

Make sure these secrets are configured in GitHub repository settings:

- `DOCKER_TOKEN` - Docker Hub authentication token

**To add secrets:**
1. Go to repository → Settings → Secrets and variables → Actions
2. Add `DOCKER_TOKEN` with your Docker Hub token

---

## Workflow Features

✅ **Configuration Validation** - Tests nginx config before building  
✅ **Docker Buildx** - Fast, efficient builds  
✅ **Registry Cache** - Reuses layers from previous builds  
✅ **Disk Space Cleanup** - Prunes Docker to prevent "no space" errors  
✅ **Multiple Tags** - Creates semantic versioning tags  
✅ **Conditional Builds** - Only builds on main/master or version tags  

---

## Testing Locally

Before pushing, you can test the workflow locally:

```bash
# Validate nginx config
docker run --rm \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/conf.d:/etc/nginx/conf.d:ro \
  nginx:alpine nginx -t

# Build image locally
docker build -t nuniesmith/fks:nginx-latest .

# Test image
docker run -d -p 8080:80 nuniesmith/fks:nginx-latest
curl http://localhost:8080/health
```

---

## Viewing Workflow Runs

After pushing, view workflow runs at:
- https://github.com/nuniesmith/fks_nginx/actions

---

## Next Steps

1. ✅ Workflow is configured
2. ✅ Pushed to repository
3. ⏳ Wait for first build to complete
4. ⏳ Verify image is pushed to Docker Hub
5. ⏳ Update Kubernetes deployment to use new image

---

**✅ GitHub Actions is now set up for nginx service!**

