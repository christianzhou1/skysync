# PowerShell script to start SkySync Application with .env.production
Write-Host "Starting SkySync Application..." -ForegroundColor Green
Write-Host ""

# Check if .env.production exists
if (Test-Path ".env.production") {
    Write-Host "Found .env.production - loading environment variables" -ForegroundColor Yellow
    
    # Detect database port from running Docker containers
    $dbPort = "5432"  # Default port
    try {
        $containerInfo = docker ps --filter "name=skysync-db" --format "{{.Ports}}" 2>&1
        if ($LASTEXITCODE -eq 0 -and $containerInfo) {
            # Docker port format: "0.0.0.0:5432->5432/tcp" or "5432->5432/tcp"
            # Extract the host port (number after colon and before ->)
            # Use a more specific pattern to avoid matching IP addresses
            if ($containerInfo -match ':(\d+)->5432') {
                $dbPort = $matches[1]
                Write-Host "  Detected database port: $dbPort" -ForegroundColor Cyan
            } elseif ($containerInfo -match '^(\d+)->5432') {
                # Format without IP: "5432->5432/tcp"
                $dbPort = $matches[1]
                Write-Host "  Detected database port: $dbPort" -ForegroundColor Cyan
            } else {
                Write-Host "  Using default database port: $dbPort (could not parse: $containerInfo)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  Using default database port: $dbPort (container not found or docker command failed)" -ForegroundColor Yellow
        }
    } catch {
        # If docker command fails, use default
        Write-Host "  Using default database port: $dbPort" -ForegroundColor Gray
    }
    
    # Load environment variables from .env.production
    Get-Content ".env.production" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # If running locally (not in Docker), replace skysync-db with localhost
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
} else {
    Write-Host "No .env.production file found - using system environment variables" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Green

# Start the application
& .\mvnw.cmd spring-boot:run "-Dspring-boot.run.jvmArguments=-Djava.awt.headless=true"

Write-Host ""
Write-Host "Application stopped. Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
