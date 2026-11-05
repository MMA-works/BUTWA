import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummaryEntity> getSummary({String? period});
  Future<List<BudgetEntity>> getBudgets({String? period});
  Future<BudgetEntity> setBudget({
    required String category,
    required double monthlyLimit,
    String? monthPeriod,
    int? alertThresholdPercentage,
  });
  Future<void> deleteBudget(String budgetId);
}
