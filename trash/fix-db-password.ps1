# Fix database password mismatch
Write-Host "Fixing database password mismatch..." -ForegroundColor Green
Write-Host ""

if (-not (Test-Path ".env.production")) {
    Write-Host ".env.production file not found!" -ForegroundColor Red
    exit 1
}

# Load password from .env.production
$dbPassword = $null
Get-Content ".env.production" | ForEach-Object {
    if ($_ -match "^DATABASE_PASSWORD=(.*)$") {
        $dbPassword = $matches[1].Trim()
    }
}

if (-not $dbPassword) {
    Write-Host "DATABASE_PASSWORD not found in .env.production!" -ForegroundColor Red
    exit 1
}

Write-Host "Password from .env.production: [HIDDEN]" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 1: Stopping and removing database container..." -ForegroundColor Yellow
docker stop skysync-db 2>&1 | Out-Null
docker rm skysync-db 2>&1 | Out-Null

Write-Host "Step 2: Removing database volume..." -ForegroundColor Yellow
# Try to find and remove the volume (Docker Compose may prefix with project name)
$volumes = docker volume ls --format "{{.Name}}" 2>&1
$volumeName = $volumes | Where-Object { $_ -match "postgres-data" } | Select-Object -First 1
if ($volumeName) {
    docker volume rm $volumeName.Trim() -f 2>&1 | Out-Null
} else {
    # Try common volume name patterns
    docker volume rm todo_postgres-data -f 2>&1 | Out-Null
    docker volume rm postgres-data -f 2>&1 | Out-Null
}

Write-Host "Step 3: Starting database with password from .env.production..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d skysync-db

if ($LASTEXITCODE -eq 0) {
    Write-Host "Step 4: Waiting for database to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Check if database is ready
    $maxAttempts = 30
    $attempt = 0
    $dbReady = $false
    while ($attempt -lt $maxAttempts -and -not $dbReady) {
        $healthCheck = docker exec skysync-db pg_isready -U todo_prod_user -d todo_prod 2>&1
        if ($LASTEXITCODE -eq 0 -and $healthCheck -match "accepting connections") {
            $dbReady = $true
            Write-Host "✓ Database is ready!" -ForegroundColor Green
        } else {
            Start-Sleep -Seconds 1
            $attempt++
        }
    }
    
    if ($dbReady) {
        Write-Host ""
        Write-Host "✓ Database password fixed! The database now uses the password from .env.production" -ForegroundColor Green
        Write-Host "You can now run: .\start.bat" -ForegroundColor Cyan
    } else {
        Write-Host "⚠ Database may not be fully ready yet. Wait a few more seconds and try again." -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Failed to start database container" -ForegroundColor Red
}

