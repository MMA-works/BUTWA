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
    if (!ApiClient.isServerOnline) {
      final tag = await SecureStorageHelper.getWalletTag() ?? '@william';
      return WalletEntity(
        id: 'w-1001',
        walletTag: tag,
        currency: 'USD',
        balance: 20600.00,
        isActive: true,
        qrCodeData: 'batwa://pay/$tag',
      );
    }
    try {
      final wallet = await remoteDataSource.getMyWallet();
      ApiClient.isServerOnline = true;
      return wallet;
    } catch (_) {
      ApiClient.isServerOnline = false;
      final tag = await SecureStorageHelper.getWalletTag() ?? '@william';
      return WalletEntity(
        id: 'w-1001',
        walletTag: tag,
        currency: 'USD',
        balance: 20600.00,
        isActive: true,
        qrCodeData: 'batwa://pay/$tag',
      );
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions({int page = 0, int size = 20}) async {
    if (!ApiClient.isServerOnline) {
      return _buildFallbackTransactions();
    }
    try {
      final list = await remoteDataSource.getTransactions(page: page, size: size);
      if (list.isNotEmpty) {
        ApiClient.isServerOnline = true;
        return list;
      }
    } catch (_) {
      ApiClient.isServerOnline = false;
    }

    return _buildFallbackTransactions();
  }

  List<TransactionEntity> _buildFallbackTransactions() {
    final now = DateTime.now();
    return [
      TransactionEntity(
        id: 'tx-1',
        referenceNumber: 'TX-94821',
        sourceWalletTag: '@william',
        sourceUserFullName: 'William Current',
        destinationWalletTag: '@dribbble',
        destinationUserFullName: 'Dribbble Pro',
        transactionType: 'TRANSFER',
        status: 'COMPLETED',
        amount: 15.00,
        fee: 0.0,
        totalDebited: 15.00,
        currency: 'USD',
        description: 'Monthly subscription',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TransactionEntity(
        id: 'tx-2',
        referenceNumber: 'TX-94820',
        sourceWalletTag: '@spotify',
        sourceUserFullName: 'Spotify Premium',
        destinationWalletTag: '@william',
        destinationUserFullName: 'William Current',
        transactionType: 'TRANSFER',
        status: 'COMPLETED',
        amount: 9.99,
        fee: 0.0,
        totalDebited: 9.99,
        currency: 'USD',
        description: 'Music Family Plan',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TransactionEntity(
        id: 'tx-3',
        referenceNumber: 'TX-94819',
        sourceWalletTag: '@mastercard',
        sourceUserFullName: 'Bank Top-Up',
        destinationWalletTag: '@william',
        destinationUserFullName: 'William Current',
        transactionType: 'TOPUP',
        status: 'COMPLETED',
        amount: 500.00,
        fee: 0.0,
        totalDebited: 500.00,
        currency: 'USD',
        description: 'Direct Bank Deposit',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionEntity(
        id: 'tx-4',
        referenceNumber: 'TX-94818',
        sourceWalletTag: '@william',
        sourceUserFullName: 'William Current',
        destinationWalletTag: '@uber',
        destinationUserFullName: 'Uber Ride',
        transactionType: 'TRANSFER',
        status: 'COMPLETED',
        amount: 24.50,
        fee: 0.0,
        totalDebited: 24.50,
        currency: 'USD',
        description: 'Ride to Airport',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
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
