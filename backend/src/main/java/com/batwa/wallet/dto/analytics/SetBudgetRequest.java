package com.batwa.wallet.dto.analytics;

import com.batwa.wallet.entity.TransactionCategory;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SetBudgetRequest {
    @NotNull(message = "Category is required")
    private TransactionCategory category;

    @NotNull(message = "Monthly limit is required")
    @DecimalMin(value = "1.00", message = "Budget limit must be at least 1.00")
    private BigDecimal monthlyLimit;

    private String monthPeriod;
    private Integer alertThresholdPercentage;
}
