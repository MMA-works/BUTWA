import 'package:batwa_wallet/features/transfer/data/models/recipient_model.dart';
import 'package:batwa_wallet/features/transfer/data/transfer_remote_datasource.dart';
import 'package:batwa_wallet/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource remoteDataSource;

  TransferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RecipientModel> lookupRecipient(String identifier) async {
    return await remoteDataSource.lookupRecipient(identifier);
  }

  @override
  Future<TransactionEntity> executeTransfer({
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? note,
  }) async {
    return await remoteDataSource.executeTransfer(
      recipientIdentifier: recipientIdentifier,
      amount: amount,
      pin: pin,
      note: note,
    );
  }
}
