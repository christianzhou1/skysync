package com.todo.service.impl;

import com.todo.api.dto.AuthResponse;
import com.todo.entity.User;
import com.todo.service.AuthService;
import com.todo.service.UserService;
import com.todo.util.JwtUtil;
import com.todo.web.dto.LoginRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Override
    public AuthResponse login(LoginRequest loginRequest) {
        // Find user by username or email
        User user = findUserByUsernameOrEmail(loginRequest.getUsernameOrEmail());
        
        // Verify password
        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        
        // Check if user is active
        if (!user.isActive()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Account is deactivated");
        }
        
        // Generate JWT token
        String token = jwtUtil.generateToken(user.getUsername(), user.getId().toString());
        
        // Calculate expiration time
        Instant expiresAt = Instant.now().plus(24, ChronoUnit.HOURS);
        
        return AuthResponse.builder()
                .token(token)
                .type("Bearer")
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .expiresAt(expiresAt)
                .build();
    }

    @Override
    public AuthResponse getCurrentUser(String token) {
        try {
            String username = jwtUtil.extractUsername(token);
            String userId = jwtUtil.extractUserId(token);
            
            if (!jwtUtil.validateToken(token, username)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
            }
            
            User user = userService.getUserById(java.util.UUID.fromString(userId));
            
            return AuthResponse.builder()
                    .token(token)
                    .type("Bearer")
                    .userId(user.getId())
                    .username(user.getUsername())
                    .email(user.getEmail())
                    .firstName(user.getFirstName())
                    .lastName(user.getLastName())
                    .expiresAt(jwtUtil.extractExpiration(token).toInstant())
                    .build();
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
    }

    private User findUserByUsernameOrEmail(String usernameOrEmail) {
        try {
            // Try to find by username first
            return userService.getUserByUsername(usernameOrEmail);
        } catch (ResponseStatusException e) {
            try {
                // If not found by username, try email
                return userService.getUserByEmail(usernameOrEmail);
            } catch (ResponseStatusException ex) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
            }
        }
    }
}
