# PowerShell script to stop and remove all Docker containers
Write-Host "Stopping and removing all Docker containers..." -ForegroundColor Green
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

# Step 1: Stop all running containers
Write-Host "Step 1: Stopping all running containers..." -ForegroundColor Cyan
Write-Host ""

$runningContainers = docker ps -q

if ($runningContainers.Count -gt 0 -and $runningContainers -ne $null) {
    Write-Host "Found $($runningContainers.Count) running container(s)" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($container in $runningContainers) {
        Write-Host "Stopping container: $container" -ForegroundColor Yellow
        docker stop $container | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Stopped successfully" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Failed to stop container" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "✅ All running containers stopped" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✅ No running containers to stop" -ForegroundColor Yellow
    Write-Host ""
}

# Step 2: Remove all containers (including stopped ones)
Write-Host "Step 2: Removing all containers..." -ForegroundColor Cyan
Write-Host ""

$allContainers = docker ps -aq

if ($allContainers.Count -eq 0 -or $allContainers -eq $null) {
    Write-Host "✅ No containers found to remove" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Found $($allContainers.Count) container(s) (including stopped)" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Warning: This will permanently delete all containers!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to cancel, or any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# Remove all containers
$successCount = 0
$failCount = 0

foreach ($container in $allContainers) {
    $containerName = docker ps -a --filter id=$container --format "{{.Names}}"
    Write-Host "Removing container: $containerName ($container)" -ForegroundColor Yellow
    docker rm -f $container 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Removed successfully" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "  ❌ Failed to remove container" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
if ($successCount -gt 0) {
    Write-Host "✅ Successfully removed $successCount container(s)" -ForegroundColor Green
}
if ($failCount -gt 0) {
    Write-Host "⚠️  Failed to remove $failCount container(s)" -ForegroundColor Yellow
}
Write-Host ""

# Verify containers are removed
$remaining = docker ps -aq
if ($remaining.Count -eq 0 -or $remaining -eq $null) {
    Write-Host "✅ Verification: No containers remain" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: $($remaining.Count) container(s) still exist" -ForegroundColor Yellow
}

