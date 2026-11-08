package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.AuthRequest;
import com.batwa.wallet.dto.request.RegisterRequest;
import com.batwa.wallet.dto.request.SetPinRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.AuthResponse;
import com.batwa.wallet.dto.response.UserResponse;
import com.batwa.wallet.entity.User;
import com.batwa.wallet.repository.UserRepository;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.AuthService;
import com.batwa.wallet.service.SecurityService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final SecurityService securityService;
    private final UserRepository userRepository;

    @GetMapping("/ping")
    public ResponseEntity<ApiResponse<String>> ping() {
        return ResponseEntity.ok(ApiResponse.ok("PONG", "BATTWAA Backend Active"));
    }

    @GetMapping("/verify-email")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyEmail(@RequestParam String email) {
        boolean valid = authService.isRealWorldEmailDomain(email);
        boolean exists = userRepository.existsByEmail(email.toLowerCase().trim());
        Map<String, Object> data = new HashMap<>();
        data.put("email", email);
        data.put("isRealDomain", valid);
        data.put("isAlreadyRegistered", exists);
        data.put("canRegister", valid && !exists);

        String message;
        if (!valid) {
            message = "This email domain does not exist in the real world.";
        } else if (exists) {
            message = "An account with this email already exists.";
        } else {
            message = "Email is authentic and ready for registration.";
        }

        return ResponseEntity.ok(ApiResponse.ok(data, message));
    }

    @GetMapping("/check-cnic")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkCnic(@RequestParam String cnic) {
        String digits = cnic.replaceAll("[^0-9]", "");
        boolean validFormat = digits.length() == 13;
        boolean available = validFormat && authService.isCnicAvailable(cnic);

        Map<String, Object> data = new HashMap<>();
        data.put("cnic", cnic);
        data.put("isValidFormat", validFormat);
        data.put("isAvailable", available);

        String message = !validFormat
                ? "CNIC must be 13 digits (XXXXX-XXXXXXX-X)"
                : (available ? "CNIC is authentic and available." : "This CNIC is already registered to an existing account.");

        return ResponseEntity.ok(ApiResponse.ok(data, message));
    }

    @GetMapping("/check-username")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkUsername(@RequestParam String username) {
        String tag = username.replace("@", "").toLowerCase().trim();
        boolean validFormat = tag.matches("^[a-z0-9_]{3,30}$");
        boolean available = validFormat && authService.isUsernameAvailable(tag);

        Map<String, Object> data = new HashMap<>();
        data.put("username", tag);
        data.put("isValidFormat", validFormat);
        data.put("isAvailable", available);

        String message = !validFormat
                ? "Username must be 3-30 alphanumeric characters or underscores"
                : (available ? "Username @" + tag + " is available!" : "Username @" + tag + " is already taken. Please choose another.");

        return ResponseEntity.ok(ApiResponse.ok(data, message));
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest) {
        AuthResponse response = authService.register(request);
        
        userRepository.findById(response.getUser().getId()).ifPresent(user -> {
            String deviceId = httpRequest.getHeader("X-Device-ID");
            String deviceName = httpRequest.getHeader("X-Device-Name");
            String osVersion = httpRequest.getHeader("X-Device-OS");
            String ipAddress = getClientIp(httpRequest);
            String userAgent = httpRequest.getHeader("User-Agent");
            securityService.recordSession(user, deviceId, deviceName, osVersion, ipAddress, userAgent);
        });

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody AuthRequest request,
            HttpServletRequest httpRequest) {
        AuthResponse response = authService.login(request);

        userRepository.findById(response.getUser().getId()).ifPresent(user -> {
            String deviceId = httpRequest.getHeader("X-Device-ID");
            String deviceName = httpRequest.getHeader("X-Device-Name");
            String osVersion = httpRequest.getHeader("X-Device-OS");
            String ipAddress = getClientIp(httpRequest);
            String userAgent = httpRequest.getHeader("User-Agent");
            securityService.recordSession(user, deviceId, deviceName, osVersion, ipAddress, userAgent);
        });

        return ResponseEntity.ok(ApiResponse.ok(response, "Login successful"));
    }

    @PostMapping("/pin")
    public ResponseEntity<ApiResponse<Void>> setPin(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody SetPinRequest request) {
        authService.setPin(userDetails.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok(null, "Transaction PIN configured successfully"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        UserResponse response = authService.getCurrentUser(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    private String getClientIp(HttpServletRequest request) {
        String xf = request.getHeader("X-Forwarded-For");
        if (xf != null && !xf.isBlank()) {
            return xf.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
