package com.batwa.wallet.service;

import com.batwa.wallet.dto.request.ChangePinRequest;
import com.batwa.wallet.dto.request.ResetPinRequest;
import com.batwa.wallet.dto.request.UpdateSecuritySettingsRequest;
import com.batwa.wallet.dto.response.SecurityAuditLogResponse;
import com.batwa.wallet.dto.response.SecuritySettingsResponse;
import com.batwa.wallet.dto.response.UserSessionResponse;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.dto.response.VerifyPinResponse;
import com.batwa.wallet.exception.AccountLockedException;
import com.batwa.wallet.exception.InvalidPinException;
import com.batwa.wallet.exception.ResourceNotFoundException;
import com.batwa.wallet.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SecurityService {

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final UserSessionRepository sessionRepository;
    private final UserSecuritySettingsRepository settingsRepository;
    private final SecurityAuditLogRepository auditLogRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void recordSession(User user, String deviceId, String deviceName, String osVersion, String ipAddress, String userAgent) {
        String cleanDeviceId = (deviceId != null && !deviceId.isBlank()) ? deviceId : "DEV-" + UUID.randomUUID().toString().substring(0, 8);
        String cleanDeviceName = (deviceName != null && !deviceName.isBlank()) ? deviceName : "Android Mobile Device";
        String cleanOs = (osVersion != null && !osVersion.isBlank()) ? osVersion : "Android";
        String cleanIp = (ipAddress != null && !ipAddress.isBlank()) ? ipAddress : "127.0.0.1";

        UserSession session = sessionRepository.findByUserIdAndDeviceIdAndIsRevokedFalse(user.getId(), cleanDeviceId)
                .orElse(null);

        if (session != null) {
            session.setDeviceName(cleanDeviceName);
            session.setOsVersion(cleanOs);
            session.setIpAddress(cleanIp);
            session.setUserAgent(userAgent);
            session.setLastActiveAt(ZonedDateTime.now());
            sessionRepository.save(session);
        } else {
            session = UserSession.builder()
                    .user(user)
                    .deviceId(cleanDeviceId)
                    .deviceName(cleanDeviceName)
                    .osVersion(cleanOs)
                    .ipAddress(cleanIp)
                    .userAgent(userAgent)
                    .isRevoked(false)
                    .lastActiveAt(ZonedDateTime.now())
                    .build();
            sessionRepository.save(session);
        }

        recordAuditLog(user, "LOGIN", "Logged in from " + cleanDeviceName + " (" + cleanIp + ")", cleanIp, cleanDeviceName);
    }

    @Transactional(readOnly = true)
    public List<UserSessionResponse> getSessions(UUID userId, String currentDeviceId) {
        return sessionRepository.findAllByUserIdAndIsRevokedFalseOrderByLastActiveAtDesc(userId)
                .stream()
                .map(s -> UserSessionResponse.builder()
                        .id(s.getId())
                        .deviceId(s.getDeviceId())
                        .deviceName(s.getDeviceName())
                        .osVersion(s.getOsVersion())
                        .ipAddress(s.getIpAddress())
                        .isCurrent(currentDeviceId != null && currentDeviceId.equalsIgnoreCase(s.getDeviceId()))
                        .lastActiveAt(s.getLastActiveAt())
                        .createdAt(s.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void revokeSession(UUID userId, UUID sessionId) {
        UserSession session = sessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Active session not found"));

        session.setRevoked(true);
        sessionRepository.save(session);

        User user = session.getUser();
        recordAuditLog(user, "SESSION_REVOKED", "Revoked session for device: " + session.getDeviceName(), session.getIpAddress(), session.getDeviceName());
    }

    @Transactional
    public void revokeOtherSessions(UUID userId, String currentDeviceId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        UserSession currentSession = null;
        if (currentDeviceId != null && !currentDeviceId.isBlank()) {
            currentSession = sessionRepository.findByUserIdAndDeviceIdAndIsRevokedFalse(userId, currentDeviceId).orElse(null);
        }

        if (currentSession != null) {
            sessionRepository.revokeAllOtherSessions(userId, currentSession.getId(), ZonedDateTime.now());
        } else {
            sessionRepository.revokeAllSessions(userId, ZonedDateTime.now());
        }

        recordAuditLog(user, "SESSION_REVOKED", "Logged out from all other active devices", "127.0.0.1", "In-App Action");
    }

    @Transactional
    public SecuritySettingsResponse getSecuritySettings(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        UserSecuritySettings settings = settingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    UserSecuritySettings newSettings = UserSecuritySettings.builder()
                            .user(user)
                            .dailySpendingLimit(new BigDecimal("50000.0000"))
                            .monthlySpendingLimit(new BigDecimal("500000.0000"))
                            .loginAlertsEnabled(true)
                            .requirePinForAllTransfers(true)
                            .build();
                    return settingsRepository.save(newSettings);
                });

        // Compute spent amounts
        ZonedDateTime startOfDay = LocalDate.now().atStartOfDay(ZoneId.systemDefault());
        ZonedDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay(ZoneId.systemDefault());

        Wallet wallet = walletRepository.findByUserId(userId).orElse(null);
        BigDecimal todaySpent = BigDecimal.ZERO;
        BigDecimal monthSpent = BigDecimal.ZERO;

        if (wallet != null) {
            todaySpent = transactionRepository.sumSpentSince(wallet.getId(), startOfDay);
            monthSpent = transactionRepository.sumSpentSince(wallet.getId(), startOfMonth);
            // Fast SQL SUM aggregate
            for (TransactionLedger tx : java.util.Collections.<TransactionLedger>emptyList()) {
                if (tx.getStatus() == TransactionStatus.SUCCESS) {
                    if (tx.getCreatedAt().isAfter(startOfDay)) {
                        todaySpent = todaySpent.add(tx.getAmount());
                    }
                    if (tx.getCreatedAt().isAfter(startOfMonth)) {
                        monthSpent = monthSpent.add(tx.getAmount());
                    }
                }
            }
        }

        double dailyPct = 0.0;
        if (settings.getDailySpendingLimit().compareTo(BigDecimal.ZERO) > 0) {
            dailyPct = todaySpent.divide(settings.getDailySpendingLimit(), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100")).doubleValue();
            if (dailyPct > 100.0) dailyPct = 100.0;
        }

        double monthPct = 0.0;
        if (settings.getMonthlySpendingLimit().compareTo(BigDecimal.ZERO) > 0) {
            monthPct = monthSpent.divide(settings.getMonthlySpendingLimit(), 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100")).doubleValue();
            if (monthPct > 100.0) monthPct = 100.0;
        }

        return SecuritySettingsResponse.builder()
                .id(settings.getId())
                .dailySpendingLimit(settings.getDailySpendingLimit().setScale(2, RoundingMode.HALF_UP))
                .monthlySpendingLimit(settings.getMonthlySpendingLimit().setScale(2, RoundingMode.HALF_UP))
                .todaySpent(todaySpent.setScale(2, RoundingMode.HALF_UP))
                .monthSpent(monthSpent.setScale(2, RoundingMode.HALF_UP))
                .dailyUsagePercentage(Math.round(dailyPct * 10.0) / 10.0)
                .monthlyUsagePercentage(Math.round(monthPct * 10.0) / 10.0)
                .loginAlertsEnabled(settings.isLoginAlertsEnabled())
                .requirePinForAllTransfers(settings.isRequirePinForAllTransfers())
                .hasPinConfigured(user.getPinHash() != null)
                .pinFailedAttempts(user.getPinFailedAttempts())
                .isAccountLocked(user.isLocked())
                .build();
    }

    @Transactional
    public SecuritySettingsResponse updateSecuritySettings(UUID userId, UpdateSecuritySettingsRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getPinHash() == null || !passwordEncoder.matches(request.getPin(), user.getPinHash())) {
            throw new InvalidPinException("Invalid transaction PIN.");
        }

        UserSecuritySettings settings = settingsRepository.findByUserId(userId)
                .orElseGet(() -> UserSecuritySettings.builder().user(user).build());

        if (request.getDailySpendingLimit() != null) {
            settings.setDailySpendingLimit(request.getDailySpendingLimit().setScale(4, RoundingMode.HALF_UP));
        }
        if (request.getMonthlySpendingLimit() != null) {
            settings.setMonthlySpendingLimit(request.getMonthlySpendingLimit().setScale(4, RoundingMode.HALF_UP));
        }
        if (request.getLoginAlertsEnabled() != null) {
            settings.setLoginAlertsEnabled(request.getLoginAlertsEnabled());
        }
        if (request.getRequirePinForAllTransfers() != null) {
            settings.setRequirePinForAllTransfers(request.getRequirePinForAllTransfers());
        }

        settingsRepository.save(settings);
        recordAuditLog(user, "LIMITS_UPDATED", "Updated daily/monthly spending limits & security preferences", "127.0.0.1", "In-App Action");

        return getSecuritySettings(userId);
    }

    @Transactional
    public void changePin(UUID userId, ChangePinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        boolean pinMatch = user.getPinHash() != null && passwordEncoder.matches(request.getCurrentPinOrPassword(), user.getPinHash());
        boolean passMatch = passwordEncoder.matches(request.getCurrentPinOrPassword(), user.getPasswordHash());

        if (!pinMatch && !passMatch) {
            user.setPinFailedAttempts(user.getPinFailedAttempts() + 1);
            if (user.getPinFailedAttempts() >= 5) {
                user.setLocked(true);
                recordAuditLog(user, "FAILED_PIN", "Account locked due to 5 consecutive failed PIN attempts", "127.0.0.1", "In-App Action");
            }
            userRepository.save(user);
            throw new InvalidPinException("Current PIN or account password does not match.");
        }

        user.setPinHash(passwordEncoder.encode(request.getNewPin()));
        user.setPinFailedAttempts(0);
        userRepository.save(user);

        recordAuditLog(user, "PIN_CHANGED", "Transaction MPIN was successfully changed", "127.0.0.1", "In-App Action");
    }

    @Transactional
    public void resetPin(UUID userId, ResetPinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.getAccountPassword(), user.getPasswordHash())) {
            throw new InvalidPinException("Invalid account password.");
        }

        user.setPinHash(passwordEncoder.encode(request.getNewPin()));
        user.setPinFailedAttempts(0);
        user.setLocked(false);
        userRepository.save(user);

        recordAuditLog(user, "PIN_CHANGED", "Transaction MPIN was reset using password verification", "127.0.0.1", "In-App Action");
    }

    @Transactional(readOnly = true)
    public List<SecurityAuditLogResponse> getAuditLogs(UUID userId) {
        return auditLogRepository.findTop50ByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(log -> SecurityAuditLogResponse.builder()
                        .id(log.getId())
                        .eventType(log.getEventType())
                        .description(log.getDescription())
                        .ipAddress(log.getIpAddress())
                        .deviceInfo(log.getDeviceInfo())
                        .timestamp(log.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public VerifyPinResponse verifyPin(UUID userId, String pin) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.isLocked()) {
            throw new AccountLockedException("Your account is locked due to security policy. Please contact customer support.");
        }

        if (user.getPinHash() == null || user.getPinHash().isBlank()) {
            throw new InvalidPinException("Transaction MPIN has not been configured yet.");
        }

        if (!passwordEncoder.matches(pin, user.getPinHash())) {
            int failedAttempts = user.getPinFailedAttempts() + 1;
            user.setPinFailedAttempts(failedAttempts);

            if (failedAttempts >= 5) {
                user.setLocked(true);
                userRepository.save(user);
                recordAuditLog(user, "FAILED_PIN", "Account locked due to 5 consecutive failed PIN attempts", "127.0.0.1", "In-App PIN Verification");
                throw new AccountLockedException("Maximum MPIN attempts exceeded. Your account has been temporarily locked for security.");
            }

            userRepository.save(user);
            int remaining = 5 - failedAttempts;
            recordAuditLog(user, "FAILED_PIN", "Incorrect MPIN entered. " + remaining + " attempts remaining.", "127.0.0.1", "In-App PIN Verification");
            throw new InvalidPinException("Incorrect MPIN. " + remaining + " attempts remaining.", remaining);
        }

        // Valid PIN: reset failed attempts counter if previously > 0
        if (user.getPinFailedAttempts() > 0) {
            user.setPinFailedAttempts(0);
            userRepository.save(user);
        }

        return VerifyPinResponse.builder()
                .valid(true)
                .message("MPIN verified successfully")
                .build();
    }

    private void recordAuditLog(User user, String eventType, String description, String ip, String device) {
        SecurityAuditLog auditLog = SecurityAuditLog.builder()
                .user(user)
                .eventType(eventType)
                .description(description)
                .ipAddress(ip)
                .deviceInfo(device)
                .build();
        auditLogRepository.save(auditLog);
    }
}