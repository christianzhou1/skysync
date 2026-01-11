# Quick Deployment Checklist

Use this checklist for every deployment to avoid common issues.

## Pre-Deployment

- [ ] `.env.production` file exists and has all required variables
- [ ] DNS A record configured (if using domain)
- [ ] SSH connection to server tested
- [ ] Frontend built (or ready to skip with `-SkipFrontendBuild`)

## Deployment Command

```powershell
powershell -ExecutionPolicy Bypass -File deploy-production.ps1 -SkipFrontendBuild
```

## Post-Deployment (On Server)

```bash
cd /opt/skysync-app

# 1. Stop conflicting services
sudo systemctl stop postgresql 2>/dev/null || true
docker ps -q --filter "publish=5432" | xargs docker stop 2>/dev/null || true

# 2. Start containers
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# 3. Wait for backend to start (~60 seconds)
sleep 60

# 4. Verify
docker-compose -f docker-compose.prod.yml --env-file .env.production ps
docker logs skysync-nginx --tail=10
docker logs skysync-backend --tail=10 | grep "Started"
```

## SSL Setup (First Time Only)

```bash
cd /opt/skysync-app
docker stop skysync-nginx
sudo apt install -y certbot
sudo certbot certonly --standalone -d skysync.christianzhou.com --email admin@christianzhou.com --agree-tos --non-interactive
mkdir -p certs
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/fullchain.pem certs/server.crt
sudo cp /etc/letsencrypt/live/skysync.christianzhou.com/privkey.pem certs/server.key
sudo chown $USER:$USER certs/server.crt certs/server.key
chmod 644 certs/server.crt && chmod 600 certs/server.key
docker-compose -f docker-compose.prod.yml --env-file .env.production restart nginx
```

## Verification

- [ ] All containers running: `docker-compose ps`
- [ ] No errors in nginx logs
- [ ] Backend health check passes: `curl http://localhost/api/actuator/health`
- [ ] Site accessible: `https://skysync.christianzhou.com`
- [ ] API docs accessible: `https://skysync.christianzhou.com/api/api-docs`

## Common Fixes

**Port 5432 in use:**
```bash
sudo lsof -i :5432
sudo kill -9 <PID>
```

**Nginx restarting (missing certs):**
```bash
# Generate self-signed certs (see SSL Setup above)
# Or check: ls -la certs/
```

**Backend 502 errors:**
```bash
# Wait 60 seconds for backend to start, then check:
docker logs skysync-backend --tail=50
```

