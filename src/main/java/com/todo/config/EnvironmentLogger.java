package com.todo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class EnvironmentLogger implements CommandLineRunner {

    private final Environment environment;
    
    @Value("${jwt.secret:NOT_SET}")
    private String jwtSecret;
    
    @Value("${spring.datasource.url:NOT_SET}")
    private String databaseUrl;
    
    @Value("${spring.datasource.username:NOT_SET}")
    private String databaseUsername;

    public EnvironmentLogger(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("\n" + "=".repeat(60));
        System.out.println("ENVIRONMENT CONFIGURATION");
        System.out.println("=".repeat(60));
        
        // Show active profiles
        String[] activeProfiles = environment.getActiveProfiles();
        if (activeProfiles.length == 0) {
            System.out.println("Active Profile: DEFAULT (no profile specified)");
        } else {
            System.out.println("Active Profiles: " + String.join(", ", activeProfiles));
        }
        
        // Show environment-specific values
        System.out.println("\nConfiguration Values:");
        System.out.println("Database URL: " + maskSensitiveInfo(databaseUrl));
        System.out.println("Database Username: " + databaseUsername);
        System.out.println("JWT Secret: " + (jwtSecret.equals("NOT_SET") ? "NOT_SET" : "[HIDDEN - " + jwtSecret.length() + " chars]"));
        System.out.println("Server Port: " + environment.getProperty("server.port", "8080"));
        System.out.println("Storage Type: " + environment.getProperty("app.storage.type", "NOT_SET"));
        
        // Show which .env file is being used
        System.out.println("Environment File: .env.local");
        
        System.out.println("=".repeat(60) + "\n");
    }
    
    private String maskSensitiveInfo(String value) {
        if (value == null || value.equals("NOT_SET")) {
            return value;
        }
        
        // Mask password in database URL
        if (value.contains("password=")) {
            return value.replaceAll("password=[^&]*", "password=***");
        }
        
        return value;
    }
}
