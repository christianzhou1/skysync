# PowerShell script to start Spring Boot backend with Docker Compose using .env.production
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Spring Boot Backend with Docker Compose" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "ERROR: .env.production file not found!" -ForegroundColor Red
    Write-Host "Please ensure .env.production exists in the project root." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found .env.production file" -ForegroundColor Green

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker is not running or not installed!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Docker is available" -ForegroundColor Green

# Check if docker-compose is available
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
$composeVersion = docker compose version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker Compose is not available!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker Compose is available" -ForegroundColor Green

# Create external network if it doesn't exist
Write-Host "Checking Docker network 'skysync-net'..." -ForegroundColor Yellow
docker network inspect skysync-net 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating Docker network 'skysync-net'..." -ForegroundColor Yellow
    docker network create skysync-net 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create network!" -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] Network 'skysync-net' created" -ForegroundColor Green
} else {
    Write-Host "[OK] Network 'skysync-net' already exists" -ForegroundColor Green
}

# Build the backend Docker image
Write-Host "Building backend Docker image..." -ForegroundColor Yellow
docker build -t skysync-backend -f Dockerfile . 2>&1 | ForEach-Object {
    if ($_ -match "ERROR|error|failed|Failed") {
        Write-Host $_ -ForegroundColor Red
    } else {
        Write-Host $_ -ForegroundColor Gray
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build Docker image!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Backend Docker image built successfully" -ForegroundColor Green

# Stop any existing containers
Write-Host "Stopping any existing containers..." -ForegroundColor Yellow
docker compose --env-file .env.production -f compose.yaml down 2>&1 | Out-Null
Write-Host "[OK] Cleaned up existing containers" -ForegroundColor Green

# Start services with Docker Compose
Write-Host ""
Write-Host "Starting services with Docker Compose..." -ForegroundColor Yellow
Write-Host "Using environment variables from .env.production" -ForegroundColor Cyan
Write-Host ""

# Start services in detached mode
docker compose --env-file .env.production -f compose.yaml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to start services!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Services started successfully!" -ForegroundColor Green
Write-Host ""

# Wait a moment for services to initialize
Start-Sleep -Seconds 2

# Show container status
Write-Host "Container Status:" -ForegroundColor Cyan
docker compose --env-file .env.production -f compose.yaml ps

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend is starting up..." -ForegroundColor Green
Write-Host ""
Write-Host "Database: skysync-db (PostgreSQL on port 5433)" -ForegroundColor Yellow
Write-Host "Backend: skysync-backend (Spring Boot on port 8080)" -ForegroundColor Yellow
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  docker compose --env-file .env.production -f compose.yaml logs -f" -ForegroundColor White
Write-Host ""
Write-Host "To stop services:" -ForegroundColor Cyan
Write-Host "  docker compose --env-file .env.production -f compose.yaml down" -ForegroundColor White
Write-Host ""
Write-Host "To view backend logs:" -ForegroundColor Cyan
Write-Host "  docker logs -f skysync-backend" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Follow backend logs
Write-Host "Following backend logs (Press Ctrl+C to stop following, containers will keep running)..." -ForegroundColor Yellow
Write-Host ""
docker logs -f skysync-backend
