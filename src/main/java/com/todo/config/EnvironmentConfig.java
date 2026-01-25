package com.todo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.core.env.PropertiesPropertySource;
import org.springframework.core.env.StandardEnvironment;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

@Configuration
@Profile("!test")
public class EnvironmentConfig {

    private final Environment environment;

    public EnvironmentConfig(Environment environment) {
        this.environment = environment;
    }

    @PostConstruct
    public void loadEnvironmentVariables() {
        String[] activeProfiles = environment.getActiveProfiles();
        System.out.println("Active profiles: " + String.join(", ", activeProfiles));
        
        // Load .env.local file for development
        loadEnvFile(".env.local");
    }

    private void loadEnvFile(String fileName) {
        try {
            File envFile = new File(fileName);
            if (!envFile.exists()) {
                System.out.println("Environment file " + fileName + " not found - using system environment variables");
                return;
            }

            Properties props = new Properties();
            props.load(new FileInputStream(envFile));
            
            System.out.println("Loading environment variables from: " + fileName);
            System.out.println("Environment variables loaded:");
            
            for (String key : props.stringPropertyNames()) {
                String value = props.getProperty(key);
                // Don't print sensitive values
                if (key.toLowerCase().contains("password") || 
                    key.toLowerCase().contains("secret") || 
                    key.toLowerCase().contains("key")) {
                    System.out.println("  " + key + " = [HIDDEN]");
                } else {
                    System.out.println("  " + key + " = " + value);
                }
                System.setProperty(key, value);
            }
            
        } catch (IOException e) {
            System.err.println("Error loading environment file " + fileName + ": " + e.getMessage());
        }
    }
}
