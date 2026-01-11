# SkySync Production Deployment Guide

This guide provides a complete, step-by-step process for deploying the SkySync application to production without common issues.

## Prerequisites

### 1. Environment Setup

- **`.env.production` file** must exist with all required variables:
  - Database credentials (DATABASE_URL, DATABASE_USERNAME, DATABASE_PASSWORD)
  - JWT_SECRET (64-character secret)
  - AWS credentials (AWS_ACCESS_KEY, AWS_SECRET_KEY, S3_BUCKET_NAME)
  - VPS configuration (VPS_HOST, APP_DIR, SSL_ENABLED)
  - SSH configuration (SSH_DIR if using custom SSH keys)

### 2. DNS Configuration

Before deploying, ensure your domain DNS is configured:
- **A Record**: `skysync` → `[your-server-ip]`
- Wait 5-30 minutes for DNS propagation
- Verify: `dig +short skysync.christianzhou.com` returns your server IP

### 3. Server Prerequisites

On the VPS server:
- Docker and Docker Compose installed
- Ports 80, 443, 8080, 5432 available
- SSH access configured
- Sufficient disk space (at least 2GB free)

## Deployment Process

### Quick Automated Deployment (Recommended)

For fully automated deployment that handles everything:

```powershell
powershell -ExecutionPolicy Bypass -File deploy-automated.ps1 -SkipFrontendBuild
```

This script automatically:
- Builds the backend
- Uploads all files
- Stops conflicting services
- Starts containers
- Waits for services to be ready
- Verifies deployment

**Note:** SSL certificates must already exist on the server (one-time setup).

### Manual Deployment Process

### Step 1: Pre-Deployment Checks

**On your local machine:**

```powershell
# Verify .env.production exists and has all required variables
cat .env.production

# Verify SSH connection works
ssh digital-ocean "echo 'SSH connection successful'"

# Check if frontend is already built (optional - can skip with -SkipFrontendBuild)
Test-Path frontend/dist/index.html
```

### Step 2: Build and Deploy

**Option A: Full Deployment (with frontend build)**

```powershell
# Make sure backend is running locally first (for API client generation)
.\mvnw.cmd spring-boot:run

# In another terminal, run deployment
powershell -ExecutionPolicy Bypass -File deploy-production.ps1
```

**Option B: Skip Frontend Build (if already built)**

```powershell
powershell -ExecutionPolicy Bypass -File deploy-production.ps1 -SkipFrontendBuild
```

### Step 3: Post-Deployment Setup on Server

**SSH into your server and run:**

```bash
cd /opt/skysync-app

# 1. Stop any conflicting services (if port 5432 is in use)
sudo systemctl stop postgresql 2>/dev/null || true
sudo systemctl disable postgresql 2>/dev/null || true
docker ps -q --filter "publish=5432" | xargs docker stop 2>/dev/null || true

# 2. Verify files are in place
ls -la
ls -la frontend/dist/
ls -la certs/ 2>/dev/null || echo "certs directory will be created"

# 3. Start containers
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# 4. Wait for services to start (backend takes ~45 seconds)
sleep 60

# 5. Check container status
docker-compose -f docker-compose.prod.yml --env-file .env.production ps
```

### Step 4: SSL Certificate Setup

**If SSL certificates don't exist, generate them:**

```bash
cd /opt/skysync-app

# Stop nginx temporarily
docker stop skysync-nginx

# Install certbot
sudo apt update
sudo apt install -y certbot

# Generate Let's Encrypt certificate
sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    -d skysync.christianzhou.com \
    --email admin@christianzhou.com \
    --agree-tos \
    --non-interactive

# Copy certificates to project directory
mkdir -p certs
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/fullchain.pem certs/server.crt
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/privkey.pem certs/server.key

# Set proper permissions
sudo chown $USER:$USER certs/server.crt certs/server.key
chmod 644 certs/server.crt
chmod 600 certs/server.key

# Restart nginx
docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx
```

### Step 5: Verification

**On the server:**

```bash
# Check all containers are running
docker-compose -f docker-compose.prod.yml --env-file .env.production ps

# Check nginx logs (should show no errors)
docker logs skysync-nginx --tail=20

# Check backend logs (should show "Started TodoApplication")
docker logs skysync-backend --tail=20

# Test backend health
docker exec skysync-nginx wget -O- -q http://skysync-backend:8080/api/actuator/health

# Test from host
curl -I http://localhost/
curl -I https://localhost/ 2>&1 | head -5
```

**From your browser:**
- Frontend: `https://skysync.christianzhou.com`
- API Docs: `https://skysync.christianzhou.com/api/api-docs`
- Health: `https://skysync.christianzhou.com/api/actuator/health`

## Common Issues and Solutions

### Issue 1: Port 5432 Already in Use

**Symptoms:** `Error: failed to bind host port for 0.0.0.0:5432`

**Solution:**
```bash
# Find and stop the process
sudo lsof -i :5432
sudo kill -9 <PID>

# Or stop system PostgreSQL
sudo systemctl stop postgresql
sudo systemctl disable postgresql
```

### Issue 2: SSL Certificates Missing

**Symptoms:** Nginx container restarting, logs show "cannot load certificate"

**Solution:**
- Follow Step 4 above to generate certificates
- Or use self-signed certificates for testing:
```bash
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/server.key \
  -out certs/server.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=skysync.christianzhou.com"
chmod 644 certs/server.crt
chmod 600 certs/server.key
docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx
```

### Issue 3: Backend 502 Errors

**Symptoms:** API returns 502 Bad Gateway

**Causes:**
- Backend still starting (takes ~45 seconds) - wait and retry
- Backend crashed - check logs: `docker logs skysync-backend`
- Network issue - verify: `docker exec skysync-nginx ping -c 2 skysync-backend`

**Solution:**
```bash
# Check backend status
docker logs skysync-backend --tail=50

# Check if backend is listening
docker exec skysync-backend netstat -tlnp | grep 8080

# Restart if needed
docker-compose -f docker-compose.prod.yml --env-file .env.production restart skysync-backend
```

### Issue 4: Frontend Files Missing

**Symptoms:** Nginx serves 404 or empty page

**Solution:**
```bash
# Verify frontend files exist
ls -la /opt/skysync-app/frontend/dist/

# If missing, re-upload or rebuild frontend
# Then restart nginx
docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx
```

### Issue 5: Environment Variables Not Loading

**Symptoms:** Docker Compose shows warnings about missing variables

**Solution:**
- Ensure `.env.production` exists on server at `/opt/skysync-app/.env.production`
- Verify file has correct format (no spaces around `=`)
- Check file permissions: `chmod 644 .env.production`

## Quick Deployment Checklist

- [ ] `.env.production` file exists with all required variables
- [ ] DNS A record configured for subdomain
- [ ] SSH connection to server works
- [ ] Port 5432 is free (no conflicting PostgreSQL)
- [ ] Frontend built (or use `-SkipFrontendBuild` flag)
- [ ] SSL certificates generated (or use self-signed for testing)
- [ ] All containers running: `docker-compose ps`
- [ ] Nginx logs show no errors
- [ ] Backend health check passes
- [ ] Site accessible via HTTPS

## Maintenance

### Updating the Application

1. Make code changes locally
2. Run deployment script: `.\deploy-production.ps1 -SkipFrontendBuild`
3. On server, restart containers if needed:
   ```bash
   cd /opt/skysync-app
   docker-compose -f docker-compose.prod.yml --env-file .env.production restart
   ```

### Renewing SSL Certificates

Let's Encrypt certificates expire every 90 days. Set up automatic renewal:

```bash
# Add to crontab
sudo crontab -e

# Add this line (runs daily at noon):
0 12 * * * /usr/bin/certbot renew --quiet --post-hook 'cd /opt/skysync-app && docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx'
```

Or manually renew:
```bash
sudo certbot renew
cd /opt/skysync-app
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/fullchain.pem certs/server.crt
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/privkey.pem certs/server.key
docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx
```

### Monitoring

**Check container status:**
```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production ps
docker stats --no-stream
```

**View logs:**
```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production logs --tail=50
docker logs skysync-backend --tail=100
docker logs skysync-nginx --tail=50
```

**Check disk space:**
```bash
df -h
docker system df
```

## Troubleshooting Commands

```bash
# Full system check
cd /opt/skysync-app
docker-compose -f docker-compose.prod.yml --env-file .env.production ps
docker logs skysync-nginx --tail=20
docker logs skysync-backend --tail=20
docker logs skysync-db --tail=20

# Test connectivity
docker exec skysync-nginx wget -O- -q http://skysync-backend:8080/api/actuator/health
docker exec skysync-backend ping -c 2 skysync-db

# Check ports
sudo netstat -tlnp | grep -E ':(80|443|8080|5432)'

# Restart everything
docker-compose -f docker-compose.prod.yml --env-file .env.production down
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

## Notes

- **Backend startup time**: The Spring Boot backend takes approximately 45-50 seconds to fully start. Initial API requests may fail with 502 until it's ready.
- **SSL certificates**: Certificates are stored on the server and persist across deployments. The deployment script won't overwrite existing certificates.
- **Database**: The PostgreSQL container uses a Docker volume, so data persists across container restarts.
- **Frontend build**: If the backend isn't running locally, use `-SkipFrontendBuild` flag to skip API client generation.

