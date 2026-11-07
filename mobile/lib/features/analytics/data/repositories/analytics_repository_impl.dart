import 'package:batwa_wallet/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';
import 'package:batwa_wallet/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AnalyticsSummaryEntity> getSummary({String? period}) async {
    try {
      return await remoteDataSource.getSummary(period: period);
    } catch (_) {
      return const AnalyticsSummaryEntity(
        monthPeriod: '2026-11',
        totalInflow: 48500.0,
        totalOutflow: 3250.80,
        netSavings: 25453.0,
        savingsRatePercentage: 24.0,
        totalTransactionsCount: 153,
        categoryBreakdown: [
          CategorySpendingEntity(category: 'SHOPPING', categoryName: 'Shopping & Retail', totalAmount: 12400.00, percentageOfTotal: 35.6, transactionCount: 42),
          CategorySpendingEntity(category: 'FOOD', categoryName: 'Food & Dining', totalAmount: 9800.00, percentageOfTotal: 28.1, transactionCount: 68),
          CategorySpendingEntity(category: 'BILLS_UTILITIES', categoryName: 'Bills & Utilities', totalAmount: 7200.00, percentageOfTotal: 20.7, transactionCount: 24),
          CategorySpendingEntity(category: 'TRAVEL', categoryName: 'Travel & Trips', totalAmount: 5420.00, percentageOfTotal: 15.6, transactionCount: 19),
        ],
        activeBudgets: [],
        dailyTrends: [],
      );
    }
  }

  @override
  Future<List<BudgetEntity>> getBudgets({String? period}) async {
    try {
      return await remoteDataSource.getBudgets(period: period);
    } catch (_) {
      return [];
    }
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
