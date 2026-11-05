class CategorySpendingEntity {
  final String category;
  final String categoryName;
  final double totalAmount;
  final double percentageOfTotal;
  final int transactionCount;

  const CategorySpendingEntity({
    required this.category,
    required this.categoryName,
    required this.totalAmount,
    required this.percentageOfTotal,
    required this.transactionCount,
  });
}

class BudgetEntity {
  final String id;
  final String category;
  final double monthlyLimit;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final String monthPeriod;
  final int alertThresholdPercentage;
  final bool isAlertTriggered;
  final bool isExceeded;
  final DateTime? createdAt;

  const BudgetEntity({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.monthPeriod,
    required this.alertThresholdPercentage,
    required this.isAlertTriggered,
    required this.isExceeded,
    this.createdAt,
  });
}

class DailyTrendEntity {
  final String date;
  final double inflow;
  final double outflow;

  const DailyTrendEntity({
    required this.date,
    required this.inflow,
    required this.outflow,
  });
}

class AnalyticsSummaryEntity {
  final String monthPeriod;
  final double totalInflow;
  final double totalOutflow;
  final double netSavings;
  final double savingsRatePercentage;
  final int totalTransactionsCount;
  final List<CategorySpendingEntity> categoryBreakdown;
  final List<BudgetEntity> activeBudgets;
  final List<DailyTrendEntity> dailyTrends;

  const AnalyticsSummaryEntity({
    required this.monthPeriod,
    required this.totalInflow,
    required this.totalOutflow,
    required this.netSavings,
    required this.savingsRatePercentage,
    required this.totalTransactionsCount,
    required this.categoryBreakdown,
    required this.activeBudgets,
    required this.dailyTrends,
  });
}
