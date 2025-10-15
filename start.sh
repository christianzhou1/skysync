#!/bin/bash

echo "Starting Todo Application..."
echo

# Check if .env.local exists
if [ -f .env.local ]; then
    echo "Found .env.local - loading environment variables"
    
    # Load environment variables from .env.local
    export $(cat .env.local | grep -v '^#' | xargs)
    
    echo "Environment variables loaded from .env.local"
else
    echo "No .env.local file found - using system environment variables"
fi

echo
echo "Starting Spring Boot application..."

# Start the application
./mvnw spring-boot:run

echo
echo "Application stopped."
