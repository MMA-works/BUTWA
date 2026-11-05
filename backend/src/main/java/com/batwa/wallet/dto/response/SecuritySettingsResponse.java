package com.batwa.wallet.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SecuritySettingsResponse {

    private UUID id;
    private BigDecimal dailySpendingLimit;
    private BigDecimal monthlySpendingLimit;
    private BigDecimal todaySpent;
    private BigDecimal monthSpent;
    private double dailyUsagePercentage;
    private double monthlyUsagePercentage;
    private boolean loginAlertsEnabled;
    private boolean requirePinForAllTransfers;
    private boolean hasPinConfigured;
    private int pinFailedAttempts;
    private boolean isAccountLocked;
}