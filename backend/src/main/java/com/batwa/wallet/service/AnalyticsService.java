package com.batwa.wallet.service;

import com.batwa.wallet.dto.analytics.*;
import com.batwa.wallet.entity.*;
import com.batwa.wallet.repository.BudgetRepository;
import com.batwa.wallet.repository.TransactionRepository;
import com.batwa.wallet.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TransactionRepository transactionRepository;
    private final BudgetRepository budgetRepository;
    private final WalletRepository walletRepository;

    @Transactional(readOnly = true)
    public AnalyticsSummaryResponse getAnalyticsSummary(User user, String monthPeriod) {
        String period = (monthPeriod == null || monthPeriod.trim().isEmpty()) 
                ? YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"))
                : monthPeriod.trim();

        YearMonth ym = YearMonth.parse(period);
        ZonedDateTime startOfMonth = ym.atDay(1).atStartOfDay(ZoneId.systemDefault());
        ZonedDateTime endOfMonth = ym.plusMonths(1).atDay(1).atStartOfDay(ZoneId.systemDefault());

        Wallet wallet = walletRepository.findByUserId(user.getId())
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        List<TransactionLedger> transactions = transactionRepository.findAllByWalletIdAndDateRange(
                wallet.getId(), startOfMonth, endOfMonth);

        BigDecimal totalInflow = BigDecimal.ZERO;
        BigDecimal totalOutflow = BigDecimal.ZERO;
        Map<TransactionCategory, BigDecimal> categorySpendMap = new EnumMap<>(TransactionCategory.class);
        Map<TransactionCategory, Long> categoryCountMap = new EnumMap<>(TransactionCategory.class);
        Map<LocalDate, BigDecimal[]> dailyMap = new TreeMap<>(); // [inflow, outflow]

        for (TransactionLedger tx : transactions) {
            if (tx.getStatus() != TransactionStatus.SUCCESS) {
                continue;
            }

            LocalDate txDate = tx.getCreatedAt().toLocalDate();
            dailyMap.putIfAbsent(txDate, new BigDecimal[]{BigDecimal.ZERO, BigDecimal.ZERO});

            boolean isSource = tx.getSourceWallet() != null && tx.getSourceWallet().getId().equals(wallet.getId());
            boolean isDest = tx.getDestinationWallet() != null && tx.getDestinationWallet().getId().equals(wallet.getId());

            if (isSource && !isDest) {
                // Outflow
                BigDecimal amountWithFee = tx.getAmount().add(tx.getFee() != null ? tx.getFee() : BigDecimal.ZERO);
                totalOutflow = totalOutflow.add(amountWithFee);
                dailyMap.get(txDate)[1] = dailyMap.get(txDate)[1].add(amountWithFee);

                TransactionCategory cat = tx.getCategory() != null ? tx.getCategory() : TransactionCategory.GENERAL;
                categorySpendMap.put(cat, categorySpendMap.getOrDefault(cat, BigDecimal.ZERO).add(amountWithFee));
                categoryCountMap.put(cat, categoryCountMap.getOrDefault(cat, 0L) + 1);
            } else if (isDest && !isSource) {
                // Inflow
                totalInflow = totalInflow.add(tx.getAmount());
                dailyMap.get(txDate)[0] = dailyMap.get(txDate)[0].add(tx.getAmount());
            } else if (isSource && isDest) {
                // Topup or internal
                totalInflow = totalInflow.add(tx.getAmount());
                dailyMap.get(txDate)[0] = dailyMap.get(txDate)[0].add(tx.getAmount());
            }
        }

        BigDecimal netSavings = totalInflow.subtract(totalOutflow);
        double savingsRate = 0.0;
        if (totalInflow.compareTo(BigDecimal.ZERO) > 0) {
            savingsRate = netSavings.divide(totalInflow, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100))
                    .doubleValue();
        }

        // Category breakdown
        BigDecimal finalTotalOutflow = totalOutflow;
        List<CategorySpendingResponse> categoryBreakdown = categorySpendMap.entrySet().stream()
                .map(entry -> {
                    double percentage = 0.0;
                    if (finalTotalOutflow.compareTo(BigDecimal.ZERO) > 0) {
                        percentage = entry.getValue().divide(finalTotalOutflow, 4, RoundingMode.HALF_UP)
                                .multiply(BigDecimal.valueOf(100))
                                .doubleValue();
                    }
                    return CategorySpendingResponse.builder()
                            .category(entry.getKey())
                            .categoryName(formatCategoryName(entry.getKey()))
                            .totalAmount(entry.getValue().setScale(2, RoundingMode.HALF_UP))
                            .percentageOfTotal(Math.round(percentage * 100.0) / 100.0)
                            .transactionCount(categoryCountMap.getOrDefault(entry.getKey(), 0L))
                            .build();
                })
                .sorted(Comparator.comparing(CategorySpendingResponse::getTotalAmount).reversed())
                .collect(Collectors.toList());

        // Budgets for this period
        List<Budget> budgets = budgetRepository.findByUserAndMonthPeriod(user, period);
        List<BudgetResponse> activeBudgets = budgets.stream()
                .map(b -> {
                    BigDecimal spent = categorySpendMap.getOrDefault(b.getCategory(), BigDecimal.ZERO);
                    BigDecimal remaining = b.getMonthlyLimit().subtract(spent);
                    double pctUsed = 0.0;
                    if (b.getMonthlyLimit().compareTo(BigDecimal.ZERO) > 0) {
                        pctUsed = spent.divide(b.getMonthlyLimit(), 4, RoundingMode.HALF_UP)
                                .multiply(BigDecimal.valueOf(100))
                                .doubleValue();
                    }
                    return BudgetResponse.builder()
                            .id(b.getId())
                            .category(b.getCategory())
                            .monthlyLimit(b.getMonthlyLimit().setScale(2, RoundingMode.HALF_UP))
                            .spentAmount(spent.setScale(2, RoundingMode.HALF_UP))
                            .remainingAmount(remaining.setScale(2, RoundingMode.HALF_UP))
                            .percentageUsed(Math.round(pctUsed * 10.0) / 10.0)
                            .monthPeriod(b.getMonthPeriod())
                            .alertThresholdPercentage(b.getAlertThresholdPercentage())
                            .isAlertTriggered(pctUsed >= b.getAlertThresholdPercentage())
                            .isExceeded(spent.compareTo(b.getMonthlyLimit()) > 0)
                            .createdAt(b.getCreatedAt())
                            .build();
                })
                .collect(Collectors.toList());

        // Daily trends
        List<DailySpendingResponse> dailyTrends = dailyMap.entrySet().stream()
                .map(e -> DailySpendingResponse.builder()
                        .date(e.getKey())
                        .inflow(e.getValue()[0].setScale(2, RoundingMode.HALF_UP))
                        .outflow(e.getValue()[1].setScale(2, RoundingMode.HALF_UP))
                        .build())
                .collect(Collectors.toList());

        return AnalyticsSummaryResponse.builder()
                .monthPeriod(period)
                .totalInflow(totalInflow.setScale(2, RoundingMode.HALF_UP))
                .totalOutflow(totalOutflow.setScale(2, RoundingMode.HALF_UP))
                .netSavings(netSavings.setScale(2, RoundingMode.HALF_UP))
                .savingsRatePercentage(Math.round(savingsRate * 100.0) / 100.0)
                .totalTransactionsCount((long) transactions.size())
                .categoryBreakdown(categoryBreakdown)
                .activeBudgets(activeBudgets)
                .dailyTrends(dailyTrends)
                .build();
    }

    @Transactional
    public BudgetResponse setBudget(User user, SetBudgetRequest request) {
        String period = (request.getMonthPeriod() == null || request.getMonthPeriod().trim().isEmpty())
                ? YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"))
                : request.getMonthPeriod().trim();

        int alertThreshold = request.getAlertThresholdPercentage() != null ? request.getAlertThresholdPercentage() : 80;

        Budget budget = budgetRepository.findByUserAndCategoryAndMonthPeriod(user, request.getCategory(), period)
                .orElse(Budget.builder()
                        .user(user)
                        .category(request.getCategory())
                        .monthPeriod(period)
                        .build());

        budget.setMonthlyLimit(request.getMonthlyLimit());
        budget.setAlertThresholdPercentage(alertThreshold);
        Budget saved = budgetRepository.save(budget);

        AnalyticsSummaryResponse summary = getAnalyticsSummary(user, period);
        return summary.getActiveBudgets().stream()
                .filter(b -> b.getId().equals(saved.getId()))
                .findFirst()
                .orElse(BudgetResponse.builder()
                        .id(saved.getId())
                        .category(saved.getCategory())
                        .monthlyLimit(saved.getMonthlyLimit())
                        .spentAmount(BigDecimal.ZERO)
                        .remainingAmount(saved.getMonthlyLimit())
                        .percentageUsed(0.0)
                        .monthPeriod(saved.getMonthPeriod())
                        .alertThresholdPercentage(saved.getAlertThresholdPercentage())
                        .isAlertTriggered(false)
                        .isExceeded(false)
                        .createdAt(saved.getCreatedAt())
                        .build());
    }

    @Transactional(readOnly = true)
    public List<BudgetResponse> getBudgets(User user, String monthPeriod) {
        String period = (monthPeriod == null || monthPeriod.trim().isEmpty())
                ? YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"))
                : monthPeriod.trim();

        AnalyticsSummaryResponse summary = getAnalyticsSummary(user, period);
        return summary.getActiveBudgets();
    }

    @Transactional
    public void deleteBudget(User user, UUID budgetId) {
        Budget budget = budgetRepository.findById(budgetId)
                .orElseThrow(() -> new RuntimeException("Budget not found"));
        if (!budget.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized to delete this budget");
        }
        budgetRepository.delete(budget);
    }

    private String formatCategoryName(TransactionCategory category) {
        if (category == null) return "General";
        switch (category) {
            case BILLS_UTILITIES: return "Bills & Utilities";
            case FOOD: return "Food & Dining";
            case SHOPPING: return "Shopping & Retail";
            case ENTERTAINMENT: return "Entertainment & Movies";
            case TRANSFERS: return "Transfers & Remittance";
            case HEALTH: return "Health & Medical";
            case EDUCATION: return "Education & Courses";
            case TRAVEL: return "Travel & Transport";
            case INVESTMENT: return "Investment & Stocks";
            default: return "General";
        }
    }
}
