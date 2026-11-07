import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/wallet/data/wallet_remote_datasource.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WalletEntity> getMyWallet() async {
    try {
      final wallet = await remoteDataSource.getMyWallet();
      ApiClient.isServerOnline = true;
      return wallet;
    } catch (_) {
      // Clean zero-meter fresh fallback if offline
      final tag = await SecureStorageHelper.getWalletTag() ?? '@batwa';
      return WalletEntity(
        id: 'w-fresh',
        walletTag: tag,
        currency: 'PKR',
        balance: 0.00,
        isActive: true,
        qrCodeData: 'batwa://pay/$tag',
      );
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions({int page = 0, int size = 20}) async {
    try {
      final list = await remoteDataSource.getTransactions(page: page, size: size);
      ApiClient.isServerOnline = true;
      return list;
    } catch (_) {
      // Return clean empty list for zero-meter fresh accounts
      return const [];
    }
  }

  @override
  Future<TransactionEntity> topUp({
    required double amount,
    required String paymentMethod,
    String? description,
  }) async {
    return await remoteDataSource.topUp(
      amount: amount,
      paymentMethod: paymentMethod,
      description: description,
    );
  }
}
