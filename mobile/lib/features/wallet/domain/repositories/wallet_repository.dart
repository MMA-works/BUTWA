import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getMyWallet();
  Future<List<TransactionEntity>> getTransactions({int page = 0, int size = 20});
  Future<TransactionEntity> topUp({
    required double amount,
    required String paymentMethod,
    String? description,
  });
}
