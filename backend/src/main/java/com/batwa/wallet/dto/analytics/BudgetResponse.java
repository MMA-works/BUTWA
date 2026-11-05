package com.batwa.wallet.dto.analytics;

import com.batwa.wallet.entity.TransactionCategory;
import lombok.*;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BudgetResponse {
    private UUID id;
    private TransactionCategory category;
    private BigDecimal monthlyLimit;
    private BigDecimal spentAmount;
    private BigDecimal remainingAmount;
    private Double percentageUsed;
    private String monthPeriod;
    private Integer alertThresholdPercentage;
    private Boolean isAlertTriggered;
    private Boolean isExceeded;
    private ZonedDateTime createdAt;
}
