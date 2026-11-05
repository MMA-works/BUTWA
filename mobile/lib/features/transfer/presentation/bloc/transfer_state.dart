import 'package:equatable/equatable.dart';
import 'package:batwa_wallet/features/transfer/data/models/recipient_model.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {}

class RecipientLookupLoading extends TransferState {}

class RecipientLookupSuccess extends TransferState {
  final RecipientModel recipient;

  const RecipientLookupSuccess({required this.recipient});

  @override
  List<Object?> get props => [recipient];
}

class RecipientLookupFailure extends TransferState {
  final String message;

  const RecipientLookupFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransferExecuting extends TransferState {}

class TransferSuccess extends TransferState {
  final TransactionEntity transaction;

  const TransferSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class TransferFailure extends TransferState {
  final String message;
  final int? remainingAttempts;

  const TransferFailure({required this.message, this.remainingAttempts});

  @override
  List<Object?> get props => [message, remainingAttempts];
}
