package com.batwa.wallet.dto.analytics;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnalyticsSummaryResponse {
    private String monthPeriod;
    private BigDecimal totalInflow;
    private BigDecimal totalOutflow;
    private BigDecimal netSavings;
    private Double savingsRatePercentage;
    private Long totalTransactionsCount;
    private List<CategorySpendingResponse> categoryBreakdown;
    private List<BudgetResponse> activeBudgets;
    private List<DailySpendingResponse> dailyTrends;
}
