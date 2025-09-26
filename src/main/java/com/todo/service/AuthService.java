package com.todo.service;

import com.todo.api.dto.AuthResponse;
import com.todo.web.dto.LoginRequest;

public interface AuthService {
    AuthResponse login(LoginRequest loginRequest);
    AuthResponse getCurrentUser(String token);
}
