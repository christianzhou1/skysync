package com.todo.security;

import com.todo.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                  FilterChain filterChain) throws ServletException, IOException {
        
        final String requestURI = request.getRequestURI();
        final String method = request.getMethod();
        log.info("Processing request: {} {}", method, requestURI);
        
        final String authHeader = request.getHeader("Authorization");
        log.info("Authorization header: {}", authHeader != null ? "Present" : "Missing");
        
        final String jwt;
        final String username;
        final String userId;

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.info("No Bearer token found, continuing without authentication");
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);
        log.info("JWT token found, length: {}", jwt.length());
        
        try {
            username = jwtUtil.extractUsername(jwt);
            userId = jwtUtil.extractUserId(jwt);
            log.info("Extracted username: {}, userId: {}", username, userId);
            
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                if (jwtUtil.validateToken(jwt, username)) {
                    log.info("JWT token is valid, setting authentication");
                    UsernamePasswordAuthenticationToken authToken = 
                        new UsernamePasswordAuthenticationToken(username, null, Collections.emptyList());
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    
                    // Store userId in the authentication context for easy access
                    authToken.setDetails(Map.of("userId", userId, "username", username));
                    
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    log.info("Authentication set successfully");
                } else {
                    log.warn("JWT token validation failed for username: {}", username);
                }
            } else {
                log.info("Username is null or authentication already exists");
            }
        } catch (Exception e) {
            log.error("JWT validation failed for request: {} {}", method, requestURI, e);
        }

        filterChain.doFilter(request, response);
    }
}
