@echo off
echo Starting SkySync Application...
echo.

REM Check if .env.local exists
if exist .env.local (
    echo Found .env.local - loading environment variables
    for /f "usebackq tokens=1,2 delims==" %%a in (".env.local") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
    echo Environment variables loaded from .env.local
) else (
    echo No .env.local file found - using system environment variables
)

echo.
echo Starting Spring Boot application...
mvnw.cmd spring-boot:run -Dspring-boot.run.jvmArguments="-Djava.awt.headless=true"

pause