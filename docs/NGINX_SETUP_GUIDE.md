# Nginx Service Setup Guide

## Current Status

### In Kubernetes
- ✅ **Nginx Ingress Controller** is running (handles routing)
- ✅ Ingress resources are configured in `repo/k8s/ingress.yaml`
- ❌ **Standalone Nginx service** is NOT deployed yet

### In Docker (Local Development)
- ✅ Configuration files exist in `repo/nginx/`
- ❌ Dockerfile and docker-compose.yml were missing (now created)

---

## Architecture Options

### Option 1: Nginx Ingress Controller (Current - Recommended for K8s)
**What it is:**
- Kubernetes-native ingress controller
- Handles routing based on Ingress resources
- Already running in your cluster

**Pros:**
- Kubernetes-native
- Automatic SSL with cert-manager
- Easy to manage via Ingress resources
- Built-in load balancing

**Cons:**
- Less control over nginx configuration
- Limited to Ingress resource features

**Status:** ✅ Currently in use

---

### Option 2: Standalone Nginx Service (New - More Control)
**What it is:**
- Dedicated nginx pod/service in Kubernetes
- Full control over nginx configuration
- Can run alongside or instead of ingress controller

**Pros:**
- Full nginx configuration control
- Custom rate limiting, caching, etc.
- Can serve static files directly
- More flexibility

**Cons:**
- More complex to manage
- Need to handle SSL certificates manually
- More resources used

**Status:** ⚠️ Not deployed yet (files created, ready to deploy)

---

## Setup Instructions

### For Kubernetes (Standalone Nginx Service)

1. **Build and push the nginx Docker image:**
   ```bash
   cd /home/jordan/Nextcloud/code/repos/fks/repo/nginx
   docker build -t nuniesmith/fks:nginx-latest .
   docker push nuniesmith/fks:nginx-latest
   ```

2. **Create SSL certificate secret (if using HTTPS):**
   ```bash
   kubectl create secret tls nginx-ssl-certs \
     --cert=ssl/fkstrading.xyz.crt \
     --key=ssl/fkstrading.xyz.key \
     -n fks-trading
   ```

3. **Deploy nginx service:**
   ```bash
   kubectl apply -f /home/jordan/Nextcloud/code/repos/fks/repo/k8s/manifests/nginx-service.yaml
   ```

4. **Verify it's running:**
   ```bash
   kubectl get pods -n fks-trading -l app=nginx
   kubectl get svc -n fks-trading nginx
   ```

5. **Update ingress to use nginx service (optional):**
   - If you want to use standalone nginx instead of ingress controller
   - Or use both (nginx service behind ingress controller)

---

### For Docker Compose (Local Development)

1. **Ensure fks-network exists:**
   ```bash
   docker network create fks-network || true
   ```

2. **Start nginx:**
   ```bash
   cd /home/jordan/Nextcloud/code/repos/fks/repo/nginx
   docker compose up -d
   ```

3. **Check logs:**
   ```bash
   docker compose logs -f nginx
   ```

4. **Test:**
   ```bash
   curl http://localhost/health
   curl https://localhost/health  # If SSL is configured
   ```

---

## Configuration Files

### Main Files
- `nginx.conf` - Main nginx configuration
- `conf.d/fkstrading.xyz.conf` - Site-specific configuration
- `Dockerfile` - Docker image definition
- `docker-compose.yml` - Docker Compose setup
- `k8s/manifests/nginx-service.yaml` - Kubernetes deployment

### SSL Certificates
- Place certificates in `ssl/` directory:
  - `fkstrading.xyz.crt` - SSL certificate
  - `fkstrading.xyz.key` - SSL private key

---

## When to Use Each Option

### Use Nginx Ingress Controller (Current) When:
- ✅ You want Kubernetes-native routing
- ✅ You want automatic SSL with cert-manager
- ✅ You're happy with Ingress resource features
- ✅ You want simpler management

### Use Standalone Nginx Service When:
- ✅ You need custom nginx configuration
- ✅ You want advanced rate limiting/caching
- ✅ You want to serve static files directly
- ✅ You need features not available in Ingress

### Use Both When:
- ✅ You want ingress controller for routing
- ✅ You want standalone nginx for specific services
- ✅ You're migrating from one to the other

---

## Next Steps

1. **Decide which approach you want:**
   - Keep using ingress controller (current)
   - Switch to standalone nginx
   - Use both

2. **If using standalone nginx:**
   - Build and push Docker image
   - Deploy to Kubernetes
   - Update DNS/load balancer to point to nginx service

3. **If keeping ingress controller:**
   - Continue using current setup
   - Standalone nginx files are available for future use

---

## Troubleshooting

### Nginx not starting
```bash
# Check logs
kubectl logs -n fks-trading -l app=nginx

# Test configuration
kubectl exec -n fks-trading -it deployment/nginx -- nginx -t
```

### SSL certificate issues
```bash
# Check if secret exists
kubectl get secret nginx-ssl-certs -n fks-trading

# Verify certificate
kubectl get secret nginx-ssl-certs -n fks-trading -o yaml
```

### Can't reach backend services
```bash
# Check if services are running
kubectl get svc -n fks-trading web flower

# Test connectivity from nginx pod
kubectl exec -n fks-trading -it deployment/nginx -- wget -O- http://web:8000/health
```

---

**Files created and ready to use!** 🚀

