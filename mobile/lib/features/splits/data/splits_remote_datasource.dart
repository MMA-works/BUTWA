import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'models/pending_split_model.dart';
import 'models/split_bill_model.dart';

abstract class SplitsRemoteDataSource {
  Future<List<SplitBillModel>> getCreatedSplits();
  Future<List<PendingSplitModel>> getPendingSplits();
  Future<SplitBillModel> createSplitBill({
    required String title,
    required double totalAmount,
    String? note,
    required List<String> participantIdentifiers,
  });
  Future<void> settleSplit({
    required String splitBillId,
    required String pin,
  });
  Future<void> cancelSplit(String splitBillId);
}

class SplitsRemoteDataSourceImpl implements SplitsRemoteDataSource {
  final ApiClient apiClient;

  SplitsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SplitBillModel>> getCreatedSplits() async {
    try {
      final response = await apiClient.client.get(ApiConstants.myCreatedSplits);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => SplitBillModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch split bills');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<PendingSplitModel>> getPendingSplits() async {
    try {
      final response = await apiClient.client.get(ApiConstants.pendingSplits);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => PendingSplitModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch pending splits');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<SplitBillModel> createSplitBill({
    required String title,
    required double totalAmount,
    String? note,
    required List<String> participantIdentifiers,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.splits,
        data: {
          'title': title,
          'totalAmount': totalAmount,
          if (note != null && note.isNotEmpty) 'note': note,
          'participants': participantIdentifiers.map((id) => {'identifier': id}).toList(),
        },
      );
      if (response.data['success'] == true) {
        return SplitBillModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to create split bill');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> settleSplit({
    required String splitBillId,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.splitSettle(splitBillId),
        data: {'pin': pin},
      );
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to settle split bill');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> cancelSplit(String splitBillId) async {
    try {
      final response = await apiClient.client.delete(ApiConstants.splitCancel(splitBillId));
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to cancel split bill');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
