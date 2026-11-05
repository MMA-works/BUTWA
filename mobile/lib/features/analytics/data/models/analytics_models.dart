import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';

class CategorySpendingModel extends CategorySpendingEntity {
  const CategorySpendingModel({
    required super.category,
    required super.categoryName,
    required super.totalAmount,
    required super.percentageOfTotal,
    required super.transactionCount,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    return CategorySpendingModel(
      category: json['category'] ?? 'GENERAL',
      categoryName: json['categoryName'] ?? 'General',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      percentageOfTotal: (json['percentageOfTotal'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.monthlyLimit,
    required super.spentAmount,
    required super.remainingAmount,
    required super.percentageUsed,
    required super.monthPeriod,
    required super.alertThresholdPercentage,
    required super.isAlertTriggered,
    required super.isExceeded,
    super.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      category: json['category'] ?? 'GENERAL',
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentageUsed'] as num?)?.toDouble() ?? 0.0,
      monthPeriod: json['monthPeriod'] ?? '',
      alertThresholdPercentage: (json['alertThresholdPercentage'] as num?)?.toInt() ?? 80,
      isAlertTriggered: json['isAlertTriggered'] ?? false,
      isExceeded: json['isExceeded'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class DailyTrendModel extends DailyTrendEntity {
  const DailyTrendModel({
    required super.date,
    required super.inflow,
    required super.outflow,
  });

  factory DailyTrendModel.fromJson(Map<String, dynamic> json) {
    return DailyTrendModel(
      date: json['date']?.toString() ?? '',
      inflow: (json['inflow'] as num?)?.toDouble() ?? 0.0,
      outflow: (json['outflow'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsSummaryModel extends AnalyticsSummaryEntity {
  const AnalyticsSummaryModel({
    required super.monthPeriod,
    required super.totalInflow,
    required super.totalOutflow,
    required super.netSavings,
    required super.savingsRatePercentage,
    required super.totalTransactionsCount,
    required super.categoryBreakdown,
    required super.activeBudgets,
    required super.dailyTrends,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    final categoriesList = (json['categoryBreakdown'] as List<dynamic>?)
            ?.map((e) => CategorySpendingModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final budgetsList = (json['activeBudgets'] as List<dynamic>?)
            ?.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final trendsList = (json['dailyTrends'] as List<dynamic>?)
            ?.map((e) => DailyTrendModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AnalyticsSummaryModel(
      monthPeriod: json['monthPeriod'] ?? '',
      totalInflow: (json['totalInflow'] as num?)?.toDouble() ?? 0.0,
      totalOutflow: (json['totalOutflow'] as num?)?.toDouble() ?? 0.0,
      netSavings: (json['netSavings'] as num?)?.toDouble() ?? 0.0,
      savingsRatePercentage: (json['savingsRatePercentage'] as num?)?.toDouble() ?? 0.0,
      totalTransactionsCount: (json['totalTransactionsCount'] as num?)?.toInt() ?? 0,
      categoryBreakdown: categoriesList,
      activeBudgets: budgetsList,
      dailyTrends: trendsList,
    );
  }
}
