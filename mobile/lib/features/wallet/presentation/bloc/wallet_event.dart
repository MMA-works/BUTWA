import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletDataEvent extends WalletEvent {}

class ToggleBalanceVisibilityEvent extends WalletEvent {}

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
