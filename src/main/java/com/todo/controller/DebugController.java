package com.todo.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/debug")
public class DebugController {

    @GetMapping("/auth")
    public ResponseEntity<Map<String, Object>> debugAuth() {
        Map<String, Object> debug = new HashMap<>();
        
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        debug.put("authenticated", auth != null && auth.isAuthenticated());
        debug.put("principal", auth != null ? auth.getPrincipal() : null);
        debug.put("authorities", auth != null ? auth.getAuthorities() : null);
        debug.put("details", auth != null ? auth.getDetails() : null);
        
        return ResponseEntity.ok(debug);
    }

    @GetMapping("/public")
    public ResponseEntity<Map<String, Object>> debugPublic() {
        Map<String, Object> debug = new HashMap<>();
        debug.put("message", "This is a public endpoint");
        debug.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(debug);
    }
}
