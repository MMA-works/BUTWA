import 'package:batwa_wallet/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';
import 'package:batwa_wallet/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AnalyticsSummaryEntity> getSummary({String? period}) {
    return remoteDataSource.getSummary(period: period);
  }

  @override
  Future<List<BudgetEntity>> getBudgets({String? period}) {
    return remoteDataSource.getBudgets(period: period);
  }

  @override
  Future<BudgetEntity> setBudget({
    required String category,
    required double monthlyLimit,
    String? monthPeriod,
    int? alertThresholdPercentage,
  }) {
    return remoteDataSource.setBudget(
      category: category,
      monthlyLimit: monthlyLimit,
      monthPeriod: monthPeriod,
      alertThresholdPercentage: alertThresholdPercentage,
    );
  }

  @override
  Future<void> deleteBudget(String budgetId) {
    return remoteDataSource.deleteBudget(budgetId);
  }
}
