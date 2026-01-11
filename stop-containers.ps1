# PowerShell script to stop all Docker containers
Write-Host "Stopping all Docker containers..." -ForegroundColor Green
Write-Host ""

# Check if Docker is available
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Docker is not installed or not available in PATH" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Docker is not installed or not available in PATH" -ForegroundColor Red
    exit 1
}

# Get all running containers
$containers = docker ps -q

if ($containers.Count -eq 0 -or $containers -eq $null) {
    Write-Host "✅ No running containers found" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Found $($containers.Count) running container(s)" -ForegroundColor Cyan
Write-Host ""

# Stop all containers
foreach ($container in $containers) {
    Write-Host "Stopping container: $container" -ForegroundColor Yellow
    docker stop $container | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Stopped successfully" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to stop container" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ All containers stopped" -ForegroundColor Green
Write-Host ""

# Verify no containers are running
$remaining = docker ps -q
if ($remaining.Count -eq 0 -or $remaining -eq $null) {
    Write-Host "✅ Verification: No containers are running" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: Some containers may still be running" -ForegroundColor Yellow
}

