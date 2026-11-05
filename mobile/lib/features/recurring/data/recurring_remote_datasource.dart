import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'models/scheduled_payment_model.dart';

abstract class RecurringRemoteDataSource {
  Future<List<ScheduledPaymentModel>> getSchedules();
  Future<ScheduledPaymentModel> createSchedule({
    required String recipientIdentifier,
    required String title,
    required double amount,
    required String frequency,
    required String pin,
  });
  Future<ScheduledPaymentModel> toggleSchedule(String scheduleId);
  Future<void> deleteSchedule(String scheduleId);
  Future<void> executeNow(String scheduleId);
}

class RecurringRemoteDataSourceImpl implements RecurringRemoteDataSource {
  final ApiClient apiClient;

  RecurringRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ScheduledPaymentModel>> getSchedules() async {
    try {
      final response = await apiClient.client.get(ApiConstants.recurring);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => ScheduledPaymentModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch scheduled payments');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduledPaymentModel> createSchedule({
    required String recipientIdentifier,
    required String title,
    required double amount,
    required String frequency,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.recurring,
        data: {
          'recipientIdentifier': recipientIdentifier,
          'title': title,
          'amount': amount,
          'frequency': frequency,
          'pin': pin,
        },
      );
      if (response.data['success'] == true) {
        return ScheduledPaymentModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to create scheduled payment');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduledPaymentModel> toggleSchedule(String scheduleId) async {
    try {
      final response = await apiClient.client.put(ApiConstants.recurringToggle(scheduleId));
      if (response.data['success'] == true) {
        return ScheduledPaymentModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to toggle schedule');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final response = await apiClient.client.delete(ApiConstants.recurringDelete(scheduleId));
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to delete schedule');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> executeNow(String scheduleId) async {
    try {
      final response = await apiClient.client.post(ApiConstants.recurringExecuteNow(scheduleId));
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to execute payment now');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}