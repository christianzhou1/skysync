# PowerShell script to start Todo Application with .env.local
Write-Host "Starting Todo Application..." -ForegroundColor Green
Write-Host ""

# Check if .env.local exists
if (Test-Path ".env.local") {
    Write-Host "Found .env.local - loading environment variables" -ForegroundColor Yellow
    
    # Load environment variables from .env.local
    Get-Content ".env.local" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
            Write-Host "  $key = [HIDDEN]" -ForegroundColor Gray
        }
    }
    Write-Host "Environment variables loaded from .env.local" -ForegroundColor Green
} else {
    Write-Host "No .env.local file found - using system environment variables" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Green

# Start the application
& .\mvnw.cmd spring-boot:run -Dspring-boot.run.jvmArguments="-Djava.awt.headless=true"

Write-Host ""
Write-Host "Application stopped. Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
