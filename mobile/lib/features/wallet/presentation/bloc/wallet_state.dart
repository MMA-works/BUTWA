import 'package:equatable/equatable.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final List<TransactionEntity> transactions;
  final bool isBalanceHidden;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
    this.isBalanceHidden = false,
  });

  WalletLoaded copyWith({
    WalletEntity? wallet,
    List<TransactionEntity>? transactions,
    bool? isBalanceHidden,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
    );
  }

  @override
  List<Object?> get props => [wallet, transactions, isBalanceHidden];
}

class TopUpInProgress extends WalletState {}

class TopUpSuccess extends WalletState {
  final TransactionEntity transaction;

  const TopUpSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
