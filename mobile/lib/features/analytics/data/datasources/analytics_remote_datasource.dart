import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/analytics/data/models/analytics_models.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsSummaryModel> getSummary({String? period});
  Future<List<BudgetModel>> getBudgets({String? period});
  Future<BudgetModel> setBudget({
    required String category,
    required double monthlyLimit,
    String? monthPeriod,
    int? alertThresholdPercentage,
  });
  Future<void> deleteBudget(String budgetId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;

  AnalyticsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AnalyticsSummaryModel> getSummary({String? period}) async {
    try {
      final query = period != null ? '?period=$period' : '';
      final response = await apiClient.client.get('${ApiConstants.analyticsSummary}$query');
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AnalyticsSummaryModel.fromJson(data);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load analytics summary');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<BudgetModel>> getBudgets({String? period}) async {
    try {
      final query = period != null ? '?period=$period' : '';
      final response = await apiClient.client.get('${ApiConstants.analyticsBudgets}$query');
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load budgets');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<BudgetModel> setBudget({
    required String category,
    required double monthlyLimit,
    String? monthPeriod,
    int? alertThresholdPercentage,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.analyticsBudgets,
        data: {
          'category': category,
          'monthlyLimit': monthlyLimit,
          if (monthPeriod != null) 'monthPeriod': monthPeriod,
          if (alertThresholdPercentage != null) 'alertThresholdPercentage': alertThresholdPercentage,
        },
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BudgetModel.fromJson(data);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to set budget');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    try {
      final response = await apiClient.client.delete(ApiConstants.analyticsBudgetDelete(budgetId));
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to delete budget');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
