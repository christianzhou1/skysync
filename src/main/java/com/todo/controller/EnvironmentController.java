package com.todo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/environment")
public class EnvironmentController {

    private final Environment environment;
    
    @Value("${jwt.secret:NOT_SET}")
    private String jwtSecret;

    public EnvironmentController(Environment environment) {
        this.environment = environment;
    }

    @GetMapping("/info")
    public Map<String, Object> getEnvironmentInfo() {
        Map<String, Object> info = new HashMap<>();
        
        String[] activeProfiles = environment.getActiveProfiles();
        info.put("activeProfiles", activeProfiles.length == 0 ? new String[]{"default"} : activeProfiles);
        info.put("serverPort", environment.getProperty("server.port"));
        info.put("storageType", environment.getProperty("app.storage.type"));
        info.put("databaseUrl", environment.getProperty("spring.datasource.url"));
        info.put("databaseUsername", environment.getProperty("spring.datasource.username"));
        info.put("jwtSecretLength", jwtSecret.equals("NOT_SET") ? 0 : jwtSecret.length());
        info.put("environmentFile", ".env.local");
        
        return info;
    }
}
