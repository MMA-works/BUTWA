import 'package:dio/dio.dart';
import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
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
      final clean = identifier.trim().replaceAll(RegExp(r'^@+'), '');
      final response = await apiClient.client.get(
        ApiConstants.lookupRecipient,
        queryParameters: {'identifier': clean},
      );
      if (response.data is Map && response.data['success'] == false) {
        throw ApiException(message: response.data['message'] ?? 'Recipient not found');
      }
      return RecipientModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map) {
          final msg = resData['message'] ?? resData['error'];
          if (msg != null && msg.toString().isNotEmpty) {
            throw ApiException(message: msg.toString());
          }
        }
      }
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
      final cleanRecipient = recipientIdentifier.trim().replaceAll(RegExp(r'^@+'), '');
      final phone = await SecureStorageHelper.getUserPhone();
      final tag = await SecureStorageHelper.getWalletTag();
      final email = await SecureStorageHelper.getUserEmail();
      String sender = (phone != null && phone.isNotEmpty)
          ? phone
          : (tag != null && tag.isNotEmpty)
              ? tag
              : (email != null && email.isNotEmpty)
                  ? email
                  : '';

      if (sender.isEmpty) {
        try {
          final myWalletRes = await apiClient.client.get(ApiConstants.myWallet);
          if (myWalletRes.data is Map && myWalletRes.data['data'] != null) {
            final wData = myWalletRes.data['data'];
            sender = (wData['accountNumber'] ?? wData['walletTag'] ?? '').toString();
            if (sender.isNotEmpty) {
              await SecureStorageHelper.saveUserProfile(phone: wData['accountNumber']);
              await SecureStorageHelper.saveUserDetails(
                fullName: wData['accountTitle'] ?? '',
                walletTag: wData['walletTag'] ?? '',
              );
            }
          }
        } catch (_) {}
      }

      final response = await apiClient.client.post(
        ApiConstants.transfer,
        data: {
          'senderId': sender,
          'senderPhone': phone ?? sender,
          'sender': sender,
          'recipientIdentifier': cleanRecipient,
          'receiver': cleanRecipient,
          'receiverQuery': cleanRecipient,
          'amount': amount,
          'pin': pin,
          'mpin': pin,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      if (response.data is Map && response.data['success'] == false) {
        throw ApiException(message: response.data['message'] ?? 'Transfer failed');
      }
      return TransactionModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map) {
          final msg = resData['message'] ?? resData['error'];
          if (msg != null && msg.toString().isNotEmpty) {
            throw ApiException(message: msg.toString());
          }
        }
      }
      throw ApiException(message: e.toString());
    }
  }
}
