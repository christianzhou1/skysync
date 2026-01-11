# PowerShell script to start SkySync Application with .env.production
Write-Host "Starting SkySync Application..." -ForegroundColor Green
Write-Host ""

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "No .env.production file found - using system environment variables" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Starting Spring Boot application..." -ForegroundColor Green
    & .\mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Djava.awt.headless=true"
    Write-Host ""
    Write-Host "Application stopped. Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "Found .env.production - loading environment variables" -ForegroundColor Yellow

# Check if database container is running
$containerCheck = docker ps --filter "name=skysync-db" --format "{{.Names}}" 2>&1
$dbContainerRunning = ($LASTEXITCODE -eq 0) -and ($containerCheck -match "skysync-db")

if ($dbContainerRunning) {
    Write-Host "  ✓ Database container is running" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Database container is not running!" -ForegroundColor Yellow
    Write-Host "   Starting database container..." -ForegroundColor Yellow
    docker-compose -f docker-compose.prod.yml --env-file .env.production up -d skysync-db 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Waiting for database to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        Write-Host "   ✓ Database container started" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Failed to start database container" -ForegroundColor Red
        Write-Host "   Please start it manually: docker-compose -f docker-compose.prod.yml --env-file .env.production up -d skysync-db" -ForegroundColor Yellow
    }
}

# Detect database port from running Docker containers
$dbPort = "5432"
$portInfo = docker ps --filter "name=skysync-db" --format "{{.Ports}}" 2>&1
if ($LASTEXITCODE -eq 0 -and $portInfo) {
    if ($portInfo -match ':([0-9]+)->5432') {
        $dbPort = $matches[1]
        Write-Host "  Detected database port: $dbPort" -ForegroundColor Cyan
    } elseif ($portInfo -match '^([0-9]+)->5432') {
        $dbPort = $matches[1]
        Write-Host "  Detected database port: $dbPort" -ForegroundColor Cyan
    }
}

# Load environment variables from .env.production
Get-Content ".env.production" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        if ($key -eq "DATABASE_URL" -and $value -like "*skysync-db*") {
            $value = $value -replace "skysync-db:5432", "localhost:$dbPort"
            Write-Host "  $key = [HIDDEN] (adjusted for local development: localhost:$dbPort)" -ForegroundColor Cyan
        } else {
            Write-Host "  $key = [HIDDEN]" -ForegroundColor Gray
        }
        
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

Write-Host "Environment variables loaded from .env.production" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Green

# Start the application
& .\mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Djava.awt.headless=true"

Write-Host ""
Write-Host "Application stopped. Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
