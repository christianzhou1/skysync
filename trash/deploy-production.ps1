# SkySync Production Deployment Script (PowerShell)
# This script deploys the entire application to VPS using JAR approach

param(
    [switch]$SkipFrontendBuild
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "Starting SkySync Production Deployment..." -ForegroundColor Green

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
    
    # Read and parse .env.production file
    Get-Content ".env.production" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
} else {
    Write-Warning ".env.production file not found!"
    Write-Warning "Using default values. Make sure to set VPS_USER, VPS_IP, and APP_DIR environment variables."
}

# Configuration
$VPS_HOST = if ($env:VPS_HOST) { $env:VPS_HOST } else { "digital-ocean" }
$APP_DIR = if ($env:APP_DIR) { $env:APP_DIR } else { "/opt/skysync-app" }
$SSL_ENABLED = if ($env:SSL_ENABLED) { $env:SSL_ENABLED } else { "true" }

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Error ".env.production file not found!"
    Write-Error "Please create .env.production with your environment variables"
    exit 1
}

Write-Step "1. Building backend with clean build..."
# Clean build to ensure no cached artifacts
Write-Status "Running Maven clean..."
& .\mvnw.cmd clean
Write-Status "Running Maven package..."
& .\mvnw.cmd package -DskipTests

if (-not $SkipFrontendBuild) {
    Write-Step "2. Building frontend..."
    Write-Host "Make sure your backend is running on http://localhost:8080 before continuing..." -ForegroundColor Yellow
    Write-Host "To start backend with .env.production: .\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
    Read-Host "Press Enter when backend is ready"

    Set-Location frontend
    Write-Status "Building frontend for production..."
    & npm run build
    Set-Location ..
}

Write-Step "3. Creating deployment package..."
# Create temporary deployment directory
if (Test-Path "deployment") {
    Remove-Item -Recurse -Force "deployment"
}
New-Item -ItemType Directory -Name "deployment" | Out-Null

# Check SSL prerequisites
if ($SSL_ENABLED -eq "true") {
    Write-Status "SSL is enabled - checking prerequisites..."
    if (-not (Test-Path "nginx-ssl.conf")) {
        Write-Warning "nginx-ssl.conf not found! Creating from nginx.conf..."
        if (Test-Path "nginx.conf") {
            Copy-Item "nginx.conf" "nginx-ssl.conf"
            Write-Warning "Please update nginx-ssl.conf with HTTPS configuration before deploying."
        } else {
            Write-Error "Neither nginx.conf nor nginx-ssl.conf found!"
            exit 1
        }
    }
}

Copy-Item "docker-compose.prod.yml" "deployment/"
Copy-Item "Dockerfile.jar" "deployment/"

# Copy SSL nginx config (HTTPS by default)
Write-Status "Using HTTPS configuration - copying nginx-ssl.conf"
if (Test-Path "nginx-ssl.conf") {
    Copy-Item "nginx-ssl.conf" "deployment/nginx.conf"
} else {
    Write-Warning "nginx-ssl.conf not found, using nginx.conf"
    Copy-Item "nginx.conf" "deployment/"
}

# Copy SSL certificates if they exist
if (Test-Path "certs") {
    Write-Status "Copying SSL certificates..."
    Copy-Item -Recurse "certs" "deployment/"
} else {
    Write-Warning "No certs directory found locally."
    Write-Warning "Make sure SSL certificates are available on the server at $APP_DIR/certs/"
    Write-Warning "You can generate them using: ./setup-letsencrypt.sh yourdomain.com your-email@example.com"
}

Copy-Item ".env.production" "deployment/"
Copy-Item "target/todo-0.0.1-SNAPSHOT.jar" "deployment/"
Copy-Item -Recurse "frontend/dist" "deployment/"

Write-Step "4. Preparing VPS directory structure..."
# Create directory structure on VPS before uploading
# Get the current user from SSH session
$prepScript = @'
CURRENT_USER=$(whoami)
if [ ! -d /opt/skysync-app ]; then
    sudo mkdir -p /opt/skysync-app
    sudo chown $CURRENT_USER:$CURRENT_USER /opt/skysync-app
fi
# Ensure directory is writable by current user
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
if ($SSH_OPTS) {
    $scpPrepCmd += " " + ($SSH_OPTS -join " ")
}
$scpPrepCmd += " `"$tempPrepScript`" `"$VPS_HOST`:$prepScriptRemote`""
Invoke-Expression $scpPrepCmd | Out-Null
$sshPrepCmd = "ssh"
if ($SSH_OPTS) {
    $sshPrepCmd += " " + ($SSH_OPTS -join " ")
}
$sshPrepCmd += " $VPS_HOST `"chmod +x $prepScriptRemote && $prepScriptRemote && rm $prepScriptRemote`""
$prepResult = Invoke-Expression $sshPrepCmd 2>&1
Write-Status "Prep script output: $prepResult"
# Verify ownership was set correctly
$verifyOwnershipCmd = "ssh"
if ($SSH_OPTS) {
    $verifyOwnershipCmd += " " + ($SSH_OPTS -join " ")
}
$verifyOwnershipCmd += " $VPS_HOST `"ls -ld /opt/skysync-app`""
Write-Status "Directory ownership:"
Invoke-Expression $verifyOwnershipCmd
Remove-Item $tempPrepScript -Force

Write-Step "5. Uploading files to VPS..."
Write-Status "VPS_HOST = $VPS_HOST"

# SSH configuration
$SSH_CONFIG = $null
$SSH_KEY = $null
$SSH_OPTS = @()

# Check for SSH config and key in different locations
$SSH_DIR = $env:SSH_DIR
if ($SSH_DIR) {
    Write-Status "Using SSH_DIR from .env.production: $SSH_DIR"
    
    
    $SSH_CONFIG_PATH = Join-Path $SSH_DIR "config"
    $SSH_KEY_PATH = Join-Path $SSH_DIR $VPS_HOST
    
    if (Test-Path $SSH_CONFIG_PATH) {
        $SSH_CONFIG = $SSH_CONFIG_PATH
        Write-Status "Found SSH config: $SSH_CONFIG"
    }
    
    if (Test-Path $SSH_KEY_PATH) {
        $SSH_KEY = $SSH_KEY_PATH
        Write-Status "Found SSH key: $SSH_KEY"
    }
} else {
    Write-Status "SSH_DIR not set, using system default SSH locations"
}

# Build SSH options
if ($SSH_CONFIG) {
    $SSH_OPTS += "-F", $SSH_CONFIG
}
if ($SSH_KEY) {
    $SSH_OPTS += "-i", $SSH_KEY
}

# Test SSH connection
Write-Status "Testing SSH connection..."
$sshTestCmd = "ssh"
if ($SSH_OPTS) {
    $sshTestCmd += " " + ($SSH_OPTS -join " ")
}
$sshTestCmd += " -o BatchMode=yes -o ConnectTimeout=5 $VPS_HOST `"echo 'SSH connection test successful'`""

try {
    Invoke-Expression $sshTestCmd | Out-Null
    Write-Status "SSH connection test successful"
} catch {
    Write-Warning "SSH connection test failed - trying without explicit config..."
    $SSH_OPTS = @()
    
    # Try basic connection
    try {
        ssh -o BatchMode=yes -o ConnectTimeout=5 $VPS_HOST "echo 'Basic SSH connection test successful'" | Out-Null
        Write-Status "Basic SSH connection successful"
    } catch {
        Write-Error "SSH connection failed completely!"
        Write-Error "Please check:"
        Write-Error "1. SSH key exists and has correct permissions"
        Write-Error "2. VPS_HOST is correctly set in .env.production"
        Write-Error "3. SSH config is properly configured"
        Write-Error "4. VPS is accessible and SSH service is running"
        exit 1
    }
}

# Upload all files to VPS
Write-Status "Uploading files to VPS..."
$scpCmd = "scp"
if ($SSH_OPTS) {
    $scpCmd += " " + ($SSH_OPTS -join " ")
}

# Upload files to /tmp first (to avoid permission issues), then move with sudo
$tmpDir = "/tmp/skysync-deploy-$(Get-Random)"
$files = @(
    "deployment/docker-compose.prod.yml",
    "deployment/Dockerfile.jar", 
    "deployment/nginx.conf",
    "deployment/.env.production",
    "deployment/todo-0.0.1-SNAPSHOT.jar"
)

# Create temp directory on VPS
$createTmpCmd = "ssh"
if ($SSH_OPTS) {
    $createTmpCmd += " " + ($SSH_OPTS -join " ")
}
$createTmpCmd += " $VPS_HOST `"mkdir -p $tmpDir`""
Invoke-Expression $createTmpCmd | Out-Null

foreach ($file in $files) {
    $target = "$VPS_HOST`:$tmpDir/$(Split-Path $file -Leaf)"
    $uploadCmd = "$scpCmd `"$file`" `"$target`""
    Write-Status "Uploading $(Split-Path $file -Leaf)..."
    $result = Invoke-Expression $uploadCmd 2>&1
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        Write-Error "Failed to upload $(Split-Path $file -Leaf): $result"
        exit 1
    }
}

# Upload frontend dist directory to temp location
$uploadCmd = "$scpCmd -r `"deployment/dist`" `"$VPS_HOST`:$tmpDir/frontend-dist`""
Write-Status "Uploading frontend files..."
Invoke-Expression $uploadCmd

# Upload SSL certificates if they exist in deployment folder
if (Test-Path "deployment/certs") {
    Write-Status "Uploading SSL certificates..."
    $uploadCmd = "$scpCmd -r `"deployment/certs`" `"$VPS_HOST`:$tmpDir/certs`""
    Invoke-Expression $uploadCmd
} else {
    Write-Warning "No certs directory in deployment folder - SSL certificates not uploaded"
}

# Move files from /tmp to final location with sudo
Write-Status "Moving files to final location..."
Write-Status "APP_DIR is set to: $APP_DIR"
# Use PowerShell variable expansion - replace $APP_DIR in the script string
$moveScriptTemplate = @'
echo "Checking files in TMP_DIR..."
ls -la TMP_DIR/ || echo "Temp directory not found or empty"
echo "Creating app directory at APP_DIR..."
sudo mkdir -p APP_DIR
sudo mkdir -p APP_DIR/frontend
echo "Moving files..."
sudo mv TMP_DIR/* APP_DIR/ 2>&1
echo "Moving hidden files..."
for file in TMP_DIR/.*; do
    if [ -f "$file" ]; then
        sudo mv "$file" APP_DIR/ 2>&1
    fi
done
echo "Moving frontend files from frontend-dist..."
if [ -d APP_DIR/frontend-dist ]; then
    sudo mkdir -p APP_DIR/frontend/dist
    sudo mv APP_DIR/frontend-dist/* APP_DIR/frontend/dist/ 2>&1
    sudo rmdir APP_DIR/frontend-dist 2>/dev/null || true
fi
echo "Moving SSL certificates if they exist..."
if [ -d APP_DIR/certs ]; then
    sudo mkdir -p APP_DIR/certs
    sudo mv TMP_DIR/certs/* APP_DIR/certs/ 2>&1 || true
    sudo chmod 644 APP_DIR/certs/server.crt 2>/dev/null || true
    sudo chmod 600 APP_DIR/certs/server.key 2>/dev/null || true
fi
echo "Setting ownership..."
sudo chown -R $(whoami):$(whoami) APP_DIR
echo "Verifying files in APP_DIR..."
ls -la APP_DIR/
echo "Verifying .env.production exists..."
ls -la APP_DIR/.env.production || echo "WARNING: .env.production not found"
rm -rf TMP_DIR
'@
$moveScript = $moveScriptTemplate -replace 'APP_DIR', $APP_DIR -replace 'TMP_DIR', $tmpDir
# Convert to Unix line endings
$moveScriptUnix = $moveScript -replace "`r`n", "`n" -replace "`r", "`n"
$tempMoveScript = [System.IO.Path]::GetTempFileName()
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempMoveScript, $moveScriptUnix, $utf8NoBom)
$moveScriptRemote = "/tmp/move-$(Get-Random).sh"
$scpMoveCmd = "scp"
if ($SSH_OPTS) {
    $scpMoveCmd += " " + ($SSH_OPTS -join " ")
}
$scpMoveCmd += " `"$tempMoveScript`" `"$VPS_HOST`:$moveScriptRemote`""
Invoke-Expression $scpMoveCmd | Out-Null
$sshMoveCmd = "ssh"
if ($SSH_OPTS) {
    $sshMoveCmd += " " + ($SSH_OPTS -join " ")
}
$sshMoveCmd += " $VPS_HOST `"chmod +x $moveScriptRemote && $moveScriptRemote && rm $moveScriptRemote`""
$moveResult = Invoke-Expression $sshMoveCmd 2>&1
Write-Status "Move script output: $moveResult"
Remove-Item $tempMoveScript -Force

Write-Step "6. Deploying on VPS..."
$sshCmd = "ssh"
if ($SSH_OPTS) {
    $sshCmd += " " + ($SSH_OPTS -join " ")
}

$deployScript = @'
set -e

# Navigate to app directory
cd /opt/skysync-app || {
    echo "ERROR: Cannot access /opt/skysync-app directory!"
    exit 1
}

# Move frontend-dist to frontend/dist if it exists
if [ -d frontend-dist ]; then
    echo "Moving frontend-dist contents to frontend/dist..."
    sudo mkdir -p frontend/dist
    sudo mv frontend-dist/* frontend/dist/ 2>/dev/null || true
    sudo rmdir frontend-dist 2>/dev/null || true
    sudo chown -R $(whoami):$(whoami) frontend/
fi
# Also check if frontend files are directly in frontend/ and move to frontend/dist/
if [ -d frontend ] && [ ! -d frontend/dist ] && [ "$(ls -A frontend/ 2>/dev/null)" ]; then
    echo "Moving frontend files to frontend/dist..."
    sudo mkdir -p frontend/dist
    sudo mv frontend/* frontend/dist/ 2>/dev/null || true
    sudo chown -R $(whoami):$(whoami) frontend/
fi

# List files to debug
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Verify critical files are present
echo "Verifying uploaded files..."
if [ ! -f docker-compose.prod.yml ]; then
    echo "ERROR: docker-compose.prod.yml not found in $(pwd)!"
    echo "Files present:"
    ls -la
    exit 1
fi
if [ ! -f .env.production ]; then
    echo "ERROR: .env.production not found in $(pwd)!"
    echo "Checking for hidden files:"
    ls -la | grep env
    exit 1
fi
if [ ! -d frontend/dist ]; then
    echo "WARNING: frontend/dist directory not found, checking frontend directory..."
    ls -la frontend/ || echo "frontend directory does not exist"
    # Don't exit, just warn - might be uploaded differently
fi
echo "All critical files verified successfully."

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker skysyncapp
    echo "Docker installed. Please log out and back in for group changes to take effect."
    exit 1
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Stop existing containers and clean up (more aggressively)
docker-compose -f docker-compose.prod.yml down || true
# Also stop any containers that might be using the ports
docker stop $(docker ps -q --filter "publish=5432") 2>/dev/null || true
docker stop $(docker ps -q --filter "publish=8080") 2>/dev/null || true
docker stop $(docker ps -q --filter "publish=80") 2>/dev/null || true
docker stop $(docker ps -q --filter "publish=443") 2>/dev/null || true
# Remove any stopped containers
docker container prune -f || true

# Clean up old images to free space
docker image prune -f || true

# Fix file permissions for frontend
chmod -R 755 frontend/dist/

# Fix SSL certificate permissions if they exist
if [ -d "certs" ]; then
    echo "Setting SSL certificate permissions..."
    chmod 644 certs/server.crt
    chmod 600 certs/server.key
    chown root:root certs/server.crt certs/server.key
fi

# Build and start the application with clean build
docker-compose -f docker-compose.prod.yml --env-file .env.production build --no-cache
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Show status
docker-compose -f docker-compose.prod.yml ps

echo "Deployment complete!"
echo "Your app should be available at: https://$(curl -s ifconfig.me)"
'@

# Execute deployment script on VPS
# Convert Windows line endings to Unix line endings
$deployScriptUnix = $deployScript -replace "`r`n", "`n" -replace "`r", "`n"

# Write script to temporary file (UTF-8 without BOM)
$tempScript = [System.IO.Path]::GetTempFileName()
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempScript, $deployScriptUnix, $utf8NoBom)

# Upload script to VPS
$tempScriptRemote = "/tmp/deploy-$(Get-Random).sh"
$scpScriptCmd = "scp"
if ($SSH_OPTS) {
    $scpScriptCmd += " " + ($SSH_OPTS -join " ")
}
$scpScriptCmd += " `"$tempScript`" `"$VPS_HOST`:$tempScriptRemote`""
Invoke-Expression $scpScriptCmd

# Execute script on VPS
$sshExecCmd = "ssh"
if ($SSH_OPTS) {
    $sshExecCmd += " " + ($SSH_OPTS -join " ")
}
$sshExecCmd += " $VPS_HOST `"chmod +x $tempScriptRemote && $tempScriptRemote && rm $tempScriptRemote`""
Invoke-Expression $sshExecCmd

# Clean up local temp file
Remove-Item $tempScript -Force

# Cleanup
Remove-Item -Recurse -Force "deployment"

Write-Status "✅ Deployment completed successfully!"
Write-Warning "Your SkySync App is now running at: https://$($env:VPS_IP)"
Write-Warning "Frontend: https://$($env:VPS_IP)"
Write-Warning "API: https://$($env:VPS_IP)/api"
Write-Warning "API Docs: https://$($env:VPS_IP)/api/api-docs"

Write-Host "🎉 Production deployment complete!" -ForegroundColor Green
