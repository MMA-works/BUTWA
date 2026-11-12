import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:batwa_wallet/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getMyWallet();
  Future<List<TransactionModel>> getTransactions({int page = 0, int size = 20});
  Future<TransactionModel> topUp({
    required double amount,
    required String paymentMethod,
    String? description,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletModel> getMyWallet() async {
    try {
      final phone = await SecureStorageHelper.getUserPhone();
      final tag = await SecureStorageHelper.getWalletTag();
      final email = await SecureStorageHelper.getUserEmail();
      final id = (phone != null && phone.isNotEmpty)
          ? phone
          : (tag != null && tag.isNotEmpty)
              ? tag
              : (email != null && email.isNotEmpty)
                  ? email
                  : '';

      final response = await apiClient.client.get(
        ApiConstants.myWallet,
        queryParameters: {
          if (id.isNotEmpty) 'identifier': id,
        },
      );
      if (response.data is Map && response.data['success'] == false) {
        throw ApiException(message: response.data['message'] ?? 'Failed to load wallet');
      }
      return WalletModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({int page = 0, int size = 20}) async {
    try {
      final phone = await SecureStorageHelper.getUserPhone();
      final tag = await SecureStorageHelper.getWalletTag();
      final email = await SecureStorageHelper.getUserEmail();
      final id = (phone != null && phone.isNotEmpty)
          ? phone
          : (tag != null && tag.isNotEmpty)
              ? tag
              : (email != null && email.isNotEmpty)
                  ? email
                  : '';

      final response = await apiClient.client.get(
        ApiConstants.transactions,
        queryParameters: {
          'page': page,
          'size': size,
          if (id.isNotEmpty) 'identifier': id,
        },
      );
      final rawData = response.data['data'];
      List<dynamic> content = [];
      if (rawData is List) {
        content = rawData;
      } else if (rawData is Map && rawData['content'] is List) {
        content = rawData['content'] as List<dynamic>;
      }
      return content.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<TransactionModel> topUp({
    required double amount,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.topUp,
        data: {
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (description != null) 'description': description,
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
