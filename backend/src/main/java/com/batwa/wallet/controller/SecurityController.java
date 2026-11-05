package com.batwa.wallet.controller;

import com.batwa.wallet.dto.request.ChangePinRequest;
import com.batwa.wallet.dto.request.ResetPinRequest;
import com.batwa.wallet.dto.request.UpdateSecuritySettingsRequest;
import com.batwa.wallet.dto.response.ApiResponse;
import com.batwa.wallet.dto.response.SecurityAuditLogResponse;
import com.batwa.wallet.dto.response.SecuritySettingsResponse;
import com.batwa.wallet.dto.response.UserSessionResponse;
import com.batwa.wallet.security.CustomUserDetails;
import com.batwa.wallet.service.SecurityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/security")
@RequiredArgsConstructor
public class SecurityController {

    private final SecurityService securityService;

    @GetMapping("/sessions")
    public ResponseEntity<ApiResponse<List<UserSessionResponse>>> getSessions(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestHeader(value = "X-Device-ID", required = false) String deviceId) {
        List<UserSessionResponse> sessions = securityService.getSessions(userDetails.getId(), deviceId);
        return ResponseEntity.ok(ApiResponse.ok(sessions));
    }

    @DeleteMapping("/sessions/{id}")
    public ResponseEntity<ApiResponse<Void>> revokeSession(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable("id") UUID sessionId) {
        securityService.revokeSession(userDetails.getId(), sessionId);
        return ResponseEntity.ok(ApiResponse.ok(null, "Device session revoked successfully"));
    }

    @PostMapping("/sessions/revoke-others")
    public ResponseEntity<ApiResponse<Void>> revokeOtherSessions(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestHeader(value = "X-Device-ID", required = false) String deviceId) {
        securityService.revokeOtherSessions(userDetails.getId(), deviceId);
        return ResponseEntity.ok(ApiResponse.ok(null, "All other device sessions have been terminated"));
    }

    @GetMapping("/settings")
    public ResponseEntity<ApiResponse<SecuritySettingsResponse>> getSettings(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        SecuritySettingsResponse settings = securityService.getSecuritySettings(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(settings));
    }

    @PutMapping("/settings")
    public ResponseEntity<ApiResponse<SecuritySettingsResponse>> updateSettings(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody UpdateSecuritySettingsRequest request) {
        SecuritySettingsResponse settings = securityService.updateSecuritySettings(userDetails.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok(settings, "Security settings and spending limits updated"));
    }

    @PostMapping("/pin/change")
    public ResponseEntity<ApiResponse<Void>> changePin(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody ChangePinRequest request) {
        securityService.changePin(userDetails.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok(null, "Transaction MPIN changed successfully"));
    }

    @PostMapping("/pin/reset")
    public ResponseEntity<ApiResponse<Void>> resetPin(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody ResetPinRequest request) {
        securityService.resetPin(userDetails.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok(null, "Transaction MPIN reset successfully"));
    }

    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<List<SecurityAuditLogResponse>>> getAuditLogs(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<SecurityAuditLogResponse> logs = securityService.getAuditLogs(userDetails.getId());
        return ResponseEntity.ok(ApiResponse.ok(logs));
    }
}