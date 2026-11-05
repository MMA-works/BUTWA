import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/transfer/data/models/recipient_model.dart';
import 'package:batwa_wallet/features/wallet/data/models/transaction_model.dart';

abstract class TransferRemoteDataSource {
  Future<RecipientModel> lookupRecipient(String identifier);
  Future<TransactionModel> executeTransfer({
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final ApiClient apiClient;

  TransferRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RecipientModel> lookupRecipient(String identifier) async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.lookupRecipient,
        queryParameters: {'identifier': identifier},
      );
      return RecipientModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<TransactionModel> executeTransfer({
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.transfer,
        data: {
          'recipientIdentifier': recipientIdentifier,
          'amount': amount,
          'pin': pin,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return TransactionModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
