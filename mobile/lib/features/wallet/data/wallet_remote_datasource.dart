import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
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
      final response = await apiClient.client.get(ApiConstants.myWallet);
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
      final response = await apiClient.client.get(
        ApiConstants.transactions,
        queryParameters: {'page': page, 'size': size},
      );
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((item) => TransactionModel.fromJson(item)).toList();
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
