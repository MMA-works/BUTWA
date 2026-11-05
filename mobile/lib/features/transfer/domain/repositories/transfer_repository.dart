import 'package:batwa_wallet/features/transfer/data/models/recipient_model.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

abstract class TransferRepository {
  Future<RecipientModel> lookupRecipient(String identifier);
  Future<TransactionEntity> executeTransfer({
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  });
}
