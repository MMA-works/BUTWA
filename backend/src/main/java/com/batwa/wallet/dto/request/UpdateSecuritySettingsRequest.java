package com.batwa.wallet.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateSecuritySettingsRequest {

    @DecimalMin(value = "500.00", message = "Daily limit must be at least 500.00")
    private BigDecimal dailySpendingLimit;

    @DecimalMin(value = "5000.00", message = "Monthly limit must be at least 5000.00")
    private BigDecimal monthlySpendingLimit;

    private Boolean loginAlertsEnabled;

    private Boolean requirePinForAllTransfers;

    @NotBlank(message = "Transaction PIN is required to confirm settings change")
    private String pin;
}