# Simple PowerShell script to start SkySync Application
Write-Host "Starting SkySync Application..." -ForegroundColor Green
Write-Host ""

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "ERROR: .env.production file not found!" -ForegroundColor Red
    Write-Host "Please create .env.production by copying env.example:" -ForegroundColor Yellow
    Write-Host "  copy env.example .env.production" -ForegroundColor Cyan
    Write-Host "Then edit .env.production and set your DATABASE_PASSWORD and other values." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "Loading environment variables from .env.production" -ForegroundColor Yellow

# Load password from .env.production for validation
$dbPassword = $null
$dbUsername = $null
Get-Content ".env.production" | ForEach-Object {
    if ($_ -match "^DATABASE_PASSWORD=(.*)$") {
        $dbPassword = $matches[1].Trim()
    }
    if ($_ -match "^DATABASE_USERNAME=(.*)$") {
        $dbUsername = $matches[1].Trim()
    }
}

if (-not $dbPassword -or -not $dbUsername) {
    Write-Host "ERROR: DATABASE_PASSWORD or DATABASE_USERNAME not found in .env.production!" -ForegroundColor Red
    Write-Host "Please ensure both are set in .env.production" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Check and start database container
$dbRunning = docker ps --filter "name=skysync-db" --format "{{.Names}}" 2>&1
$dbWasRunning = ($LASTEXITCODE -eq 0) -and ($dbRunning -match "skysync-db")

if (-not $dbWasRunning) {
    Write-Host "Starting database container..." -ForegroundColor Yellow
    docker-compose -f docker-compose.prod.yml --env-file .env.production up -d skysync-db 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to start database container!" -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
} else {
    Write-Host "Database container is already running" -ForegroundColor Green
}

# Wait for database to be ready
Write-Host "Waiting for database to be ready (this may take 10-15 seconds)..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$dbReady = $false
while ($attempt -lt $maxAttempts -and -not $dbReady) {
    Start-Sleep -Seconds 1
    $healthCheck = docker exec skysync-db pg_isready -U $dbUsername -d todo_prod 2>&1
    if ($LASTEXITCODE -eq 0 -and $healthCheck -match "accepting connections") {
        $dbReady = $true
        Write-Host "Database is ready!" -ForegroundColor Green
    }
    $attempt++
}

if (-not $dbReady) {
    Write-Host "Warning: Database may not be fully ready yet." -ForegroundColor Yellow
}

# Get database port
$dbPort = "5432"
$ports = docker ps --filter "name=skysync-db" --format "{{.Ports}}" 2>&1
if ($ports -match ':([0-9]+)->5432') {
    $dbPort = $matches[1]
}

# Load .env.production file first (we need DATABASE_URL for testing)
$envContent = Get-Content ".env.production"
$databaseUrl = $null
foreach ($line in $envContent) {
    if ($line -match "^([^#][^=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        if ($key -eq "DATABASE_URL") {
            $databaseUrl = $value
            # Adjust for localhost connection
            if ($value -like "*skysync-db*") {
                $value = $value -replace "skysync-db:5432", "localhost:$dbPort"
            }
        }
        
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

# Test database authentication from host (same way Spring Boot will connect)
Write-Host "Testing database authentication from host..." -ForegroundColor Yellow

# Check if psql is available on the host
$psqlAvailable = $false
$psqlPath = $null
if (Get-Command psql -ErrorAction SilentlyContinue) {
    $psqlAvailable = $true
    $psqlPath = "psql"
} elseif (Test-Path "C:\Program Files\PostgreSQL\*\bin\psql.exe") {
    $psqlPath = (Get-ChildItem "C:\Program Files\PostgreSQL\*\bin\psql.exe" | Select-Object -First 1).FullName
    $psqlAvailable = $true
}

$authFailed = $false
if ($psqlAvailable) {
    # Test connection using psql from host
    $env:PGPASSWORD = $dbPassword
    $testUrl = $env:DATABASE_URL -replace "jdbc:postgresql://", ""
    if ($testUrl -match "([^:]+):(\d+)/(.+)") {
        $dbHost = $matches[1]
        $dbPort = $matches[2]
        $db = $matches[3]
        $authTest = & $psqlPath -h $dbHost -p $dbPort -U $dbUsername -d $db -c "SELECT 1;" 2>&1
        Remove-Item Env:\PGPASSWORD
        if ($LASTEXITCODE -ne 0 -or $authTest -match "password authentication failed" -or $authTest -match "FATAL.*password") {
            $authFailed = $true
        } else {
            Write-Host "Database authentication successful!" -ForegroundColor Green
        }
    }
} else {
    # psql not available - if database was already running, assume it might have wrong password
    # We'll let Spring Boot test it, but warn the user
    if ($dbWasRunning) {
        Write-Host "Warning: Database container was already running." -ForegroundColor Yellow
        Write-Host "If authentication fails, the database may have been initialized with a different password." -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "Database container started with credentials from .env.production" -ForegroundColor Green
    }
}

# If authentication failed, automatically fix it
if ($authFailed) {
    Write-Host ""
    Write-Host "ERROR: Password authentication failed!" -ForegroundColor Red
    Write-Host "The database was initialized with a different password than what's in .env.production" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Automatically fixing database password..." -ForegroundColor Cyan
    Write-Host "WARNING: This will delete all existing data in the database!" -ForegroundColor Red
    Write-Host ""
    
    # Run the fix script
    if (Test-Path ".\fix-db-password.ps1") {
        & .\fix-db-password.ps1
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Database password fixed! Continuing with startup..." -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "Failed to fix database password automatically." -ForegroundColor Red
            Write-Host "Please run .\fix-db-password.ps1 manually and try again." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    } else {
        Write-Host "fix-db-password.ps1 not found! Cannot automatically fix." -ForegroundColor Red
        Write-Host "Please create the fix script or manually reset the database." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

Write-Host "Environment variables loaded" -ForegroundColor Green

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Green
& .\mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Djava.awt.headless=true"

Write-Host ""
Write-Host "Application stopped. Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

