# SkySync Fully Automated Deployment Script
# This script completely automates the deployment process
# SSL certificates are assumed to already exist on the server

param(
    [switch]$SkipFrontendBuild
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Fully Automated SkySync Deployment..." -ForegroundColor Green
Write-Host ""

# Function to print colored status messages
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Blue
}

# Load environment variables from .env.production
if (Test-Path ".env.production") {
    Write-Status "Loading environment variables from .env.production..."
    
    Get-Content ".env.production" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
} else {
    Write-Error ".env.production file not found!"
    Write-Error "Please create .env.production with your environment variables"
    exit 1
}

# Configuration
$VPS_HOST = if ($env:VPS_HOST) { $env:VPS_HOST } else { "digital-ocean" }
$APP_DIR = if ($env:APP_DIR) { $env:APP_DIR } else { "/opt/skysync-app" }
$SSL_ENABLED = if ($env:SSL_ENABLED) { $env:SSL_ENABLED } else { "true" }

Write-Step "1. Building backend..."
Write-Status "Running Maven clean..."
& .\mvnw.cmd clean | Out-Null
Write-Status "Running Maven package..."
& .\mvnw.cmd package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Error "Backend build failed!"
    exit 1
}

if (-not $SkipFrontendBuild) {
    Write-Step "2. Building frontend..."
    Write-Host "⚠️  Frontend build requires backend to be running on http://localhost:8080" -ForegroundColor Yellow
    Write-Host "   To start backend: .\start.ps1" -ForegroundColor Yellow
    Write-Host "   Or use: .\deploy-automated.ps1 -SkipFrontendBuild (if frontend is already built)" -ForegroundColor Yellow
    $response = Read-Host "Press Enter when backend is ready (or 's' to skip frontend build)"
    if ($response -eq 's') {
        Write-Warning "Skipping frontend build..."
        $SkipFrontendBuild = $true
    } else {
        # Verify backend is running
        try {
            $healthCheck = Invoke-WebRequest -Uri "http://localhost:8080/api/actuator/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            Write-Status "Backend is running and healthy"
        } catch {
            Write-Error "Backend is not responding at http://localhost:8080/api/actuator/health"
            Write-Error "Please start the backend first using: .\start.ps1"
            exit 1
        }
        
        Set-Location frontend
        Write-Status "Building frontend for production..."
        & npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Frontend build failed!"
            Set-Location ..
            exit 1
        }
        Set-Location ..
    }
} else {
    Write-Status "Skipping frontend build (using existing dist)..."
    if (-not (Test-Path "frontend/dist/index.html")) {
        Write-Warning "Frontend dist not found! Building frontend anyway..."
        Set-Location frontend
        & npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Frontend build failed!"
            Set-Location ..
            exit 1
        }
        Set-Location ..
    }
}

Write-Step "3. Creating deployment package..."
if (Test-Path "deployment") {
    Remove-Item -Recurse -Force "deployment"
}
New-Item -ItemType Directory -Name "deployment" | Out-Null

# Copy files
Copy-Item "docker-compose.prod.yml" "deployment/"
Copy-Item "Dockerfile.jar" "deployment/"

# Copy nginx config
if ($SSL_ENABLED -eq "true") {
    Write-Status "Using HTTPS configuration..."
    if (Test-Path "nginx-ssl.conf") {
        Copy-Item "nginx-ssl.conf" "deployment/nginx.conf"
    } else {
        Write-Warning "nginx-ssl.conf not found, using nginx.conf"
        Copy-Item "nginx.conf" "deployment/"
    }
} else {
    Write-Status "Using HTTP configuration..."
    Copy-Item "nginx.conf" "deployment/"
}

Copy-Item ".env.production" "deployment/"
Copy-Item "target/todo-0.0.1-SNAPSHOT.jar" "deployment/"
Copy-Item -Recurse "frontend/dist" "deployment/"

Write-Step "4. Preparing VPS and uploading files..."
# Create directory structure on VPS
$prepScript = @'
CURRENT_USER=$(whoami)
if [ ! -d /opt/skysync-app ]; then
    sudo mkdir -p /opt/skysync-app
    sudo chown $CURRENT_USER:$CURRENT_USER /opt/skysync-app
fi
sudo chown -R $CURRENT_USER:$CURRENT_USER /opt/skysync-app 2>/dev/null || true
if [ ! -d /opt/skysync-app/frontend ]; then
    mkdir -p /opt/skysync-app/frontend
    chmod 755 /opt/skysync-app/frontend
fi
'@
$prepScriptUnix = $prepScript -replace "`r`n", "`n" -replace "`r", "`n"
$tempPrepScript = [System.IO.Path]::GetTempFileName()
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempPrepScript, $prepScriptUnix, $utf8NoBom)
$prepScriptRemote = "/tmp/prep-$(Get-Random).sh"
$scpPrepCmd = "scp"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $scpPrepCmd += " -i `"$sshKey`""
    }
}
$scpPrepCmd += " `"$tempPrepScript`" `"$VPS_HOST`:$prepScriptRemote`""
Invoke-Expression $scpPrepCmd | Out-Null
$sshPrepCmd = "ssh"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $sshPrepCmd += " -i `"$sshKey`""
    }
}
$sshPrepCmd += " $VPS_HOST `"chmod +x $prepScriptRemote && $prepScriptRemote && rm $prepScriptRemote`""
Invoke-Expression $sshPrepCmd | Out-Null
Remove-Item $tempPrepScript -Force

# Test SSH connection
Write-Status "Testing SSH connection..."
$sshTestCmd = "ssh"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $sshTestCmd += " -i `"$sshKey`""
    }
}
$sshTestCmd += " -o BatchMode=yes -o ConnectTimeout=5 $VPS_HOST `"echo 'SSH OK'`""
try {
    Invoke-Expression $sshTestCmd | Out-Null
    Write-Status "SSH connection successful"
} catch {
    Write-Error "SSH connection failed!"
    exit 1
}

# Upload files to /tmp first, then move with sudo
$tmpDir = "/tmp/skysync-deploy-$(Get-Random)"
$scpCmd = "scp"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $scpCmd += " -i `"$sshKey`""
    }
}

# Create temp directory on VPS
$createTmpCmd = "ssh"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $createTmpCmd += " -i `"$sshKey`""
    }
}
$createTmpCmd += " $VPS_HOST `"mkdir -p $tmpDir`""
Invoke-Expression $createTmpCmd | Out-Null

# Upload files
$files = @(
    "deployment/docker-compose.prod.yml",
    "deployment/Dockerfile.jar", 
    "deployment/nginx.conf",
    "deployment/.env.production",
    "deployment/todo-0.0.1-SNAPSHOT.jar"
)

foreach ($file in $files) {
    $target = "$VPS_HOST`:$tmpDir/$(Split-Path $file -Leaf)"
    $uploadCmd = "$scpCmd `"$file`" `"$target`""
    Write-Status "Uploading $(Split-Path $file -Leaf)..."
    Invoke-Expression $uploadCmd | Out-Null
}

# Upload frontend
$uploadCmd = "$scpCmd -r `"deployment/dist`" `"$VPS_HOST`:$tmpDir/frontend-dist`""
Write-Status "Uploading frontend files..."
Invoke-Expression $uploadCmd | Out-Null

# Move files to final location
Write-Status "Moving files to final location..."
$moveScriptTemplate = @'
echo "Moving files to APP_DIR..."
sudo mkdir -p APP_DIR
sudo mkdir -p APP_DIR/frontend/dist
sudo mv TMP_DIR/* APP_DIR/ 2>&1
for file in TMP_DIR/.*; do
    if [ -f "$file" ]; then
        sudo mv "$file" APP_DIR/ 2>&1
    fi
done
if [ -d TMP_DIR/frontend-dist ]; then
    sudo mv TMP_DIR/frontend-dist/* APP_DIR/frontend/dist/ 2>&1 || true
    sudo rmdir TMP_DIR/frontend-dist 2>/dev/null || true
fi
sudo chown -R $(whoami):$(whoami) APP_DIR
rm -rf TMP_DIR
'@
$moveScript = $moveScriptTemplate -replace 'APP_DIR', $APP_DIR -replace 'TMP_DIR', $tmpDir
$moveScriptUnix = $moveScript -replace "`r`n", "`n" -replace "`r", "`n"
$tempMoveScript = [System.IO.Path]::GetTempFileName()
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempMoveScript, $moveScriptUnix, $utf8NoBom)
$moveScriptRemote = "/tmp/move-$(Get-Random).sh"
$scpMoveCmd = "scp"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $scpMoveCmd += " -i `"$sshKey`""
    }
}
$scpMoveCmd += " `"$tempMoveScript`" `"$VPS_HOST`:$moveScriptRemote`""
Invoke-Expression $scpMoveCmd | Out-Null
$sshMoveCmd = "ssh"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $sshMoveCmd += " -i `"$sshKey`""
    }
}
$sshMoveCmd += " $VPS_HOST `"chmod +x $moveScriptRemote && $moveScriptRemote && rm $moveScriptRemote`""
Invoke-Expression $sshMoveCmd | Out-Null
Remove-Item $tempMoveScript -Force

Write-Step "5. Deploying on VPS (automated)..."
$deployScript = @'
set -e

cd APP_DIR

# Stop conflicting services
echo "Stopping conflicting services..."
sudo systemctl stop postgresql 2>/dev/null || true
sudo systemctl disable postgresql 2>/dev/null || true
docker ps -q --filter "publish=5432" | xargs docker stop 2>/dev/null || true
docker ps -q --filter "publish=8080" | xargs docker stop 2>/dev/null || true
docker ps -q --filter "publish=80" | xargs docker stop 2>/dev/null || true
docker ps -q --filter "publish=443" | xargs docker stop 2>/dev/null || true

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    echo "Docker installed. Please log out and back in for group changes to take effect."
    exit 1
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Stop existing containers
echo "Stopping existing containers..."
docker-compose -f docker-compose.prod.yml --env-file .env.production down || true

# Clean up
docker container prune -f || true
docker image prune -f || true

# Fix file permissions
chmod -R 755 frontend/dist/ 2>/dev/null || true

# Fix SSL certificate permissions if they exist
if [ -d "certs" ] && [ -f "certs/server.crt" ]; then
    echo "Setting SSL certificate permissions..."
    chmod 644 certs/server.crt 2>/dev/null || true
    chmod 600 certs/server.key 2>/dev/null || true
fi

# Move frontend-dist to frontend/dist if it exists
if [ -d frontend-dist ]; then
    echo "Moving frontend-dist to frontend/dist..."
    sudo mkdir -p frontend/dist
    sudo mv frontend-dist/* frontend/dist/ 2>/dev/null || true
    sudo rmdir frontend-dist 2>/dev/null || true
    sudo chown -R $(whoami):$(whoami) frontend/
fi

# Build and start the application
echo "Building and starting containers..."
docker-compose -f docker-compose.prod.yml --env-file .env.production build --no-cache
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# Wait for services to start
echo "Waiting for services to start (backend takes ~45 seconds)..."
sleep 60

# Show status
echo ""
echo "Container Status:"
docker-compose -f docker-compose.prod.yml --env-file .env.production ps

# Verify services
echo ""
echo "Verifying services..."
if docker exec skysync-nginx wget -O- -q http://skysync-backend:8080/api/actuator/health 2>&1 | grep -q "UP"; then
    echo "✅ Backend health check: PASSED"
else
    echo "⚠️  Backend health check: FAILED (may still be starting)"
fi

echo ""
echo "✅ Deployment complete!"
'@
$deployScriptUnix = $deployScript -replace "`r`n", "`n" -replace "`r", "`n" -replace 'APP_DIR', $APP_DIR
$tempDeployScript = [System.IO.Path]::GetTempFileName()
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempDeployScript, $deployScriptUnix, $utf8NoBom)
$deployScriptRemote = "/tmp/deploy-$(Get-Random).sh"
$scpDeployCmd = "scp"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $scpDeployCmd += " -i `"$sshKey`""
    }
}
$scpDeployCmd += " `"$tempDeployScript`" `"$VPS_HOST`:$deployScriptRemote`""
Invoke-Expression $scpDeployCmd | Out-Null
$sshDeployCmd = "ssh"
if ($env:SSH_DIR) {
    $sshKey = Join-Path $env:SSH_DIR $VPS_HOST
    if (Test-Path $sshKey) {
        $sshDeployCmd += " -i `"$sshKey`""
    }
}
$sshDeployCmd += " $VPS_HOST `"chmod +x $deployScriptRemote && $deployScriptRemote && rm $deployScriptRemote`""
Write-Status "Executing deployment on server (this may take 2-3 minutes)..."
Invoke-Expression $sshDeployCmd
Remove-Item $tempDeployScript -Force

# Cleanup
Remove-Item -Recurse -Force "deployment"

Write-Host ""
Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Your SkySync App should now be running at:" -ForegroundColor Cyan
if ($SSL_ENABLED -eq "true") {
    Write-Host "  🌐 Frontend: https://skysync.christianzhou.com" -ForegroundColor Yellow
    Write-Host "  🔌 API: https://skysync.christianzhou.com/api" -ForegroundColor Yellow
    Write-Host "  📚 API Docs: https://skysync.christianzhou.com/api/api-docs" -ForegroundColor Yellow
} else {
    Write-Host "  🌐 Frontend: http://$($env:VPS_IP)" -ForegroundColor Yellow
    Write-Host "  🔌 API: http://$($env:VPS_IP)/api" -ForegroundColor Yellow
    Write-Host "  📚 API Docs: http://$($env:VPS_IP)/api/api-docs" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "🎉 Fully automated deployment complete!" -ForegroundColor Green

