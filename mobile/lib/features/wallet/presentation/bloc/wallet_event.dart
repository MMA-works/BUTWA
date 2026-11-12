import 'package:equatable/equatable.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletDataEvent extends WalletEvent {}

class ToggleBalanceVisibilityEvent extends WalletEvent {}

class OptimisticTransferRecordedEvent extends WalletEvent {
  final TransactionEntity transaction;
  final double debitedAmount;
  final double? newBalance;

  const OptimisticTransferRecordedEvent({
    required this.transaction,
    required this.debitedAmount,
    this.newBalance,
  });

  @override
  List<Object?> get props => [transaction, debitedAmount, newBalance];
}

class TopUpSubmittedEvent extends WalletEvent {
  final double amount;
  final String paymentMethod;
  final String? description;

  const TopUpSubmittedEvent({
    required this.amount,
    required this.paymentMethod,
    this.description,
  });

  @override
  List<Object?> get props => [amount, paymentMethod, description];
}
