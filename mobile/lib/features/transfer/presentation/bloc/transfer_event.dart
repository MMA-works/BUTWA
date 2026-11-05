import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class LookupRecipientEvent extends TransferEvent {
  final String identifier;

  const LookupRecipientEvent({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}

class ResetRecipientEvent extends TransferEvent {}

class ExecuteTransferEvent extends TransferEvent {
  final String recipientIdentifier;
  final double amount;
  final String pin;
  final String? note;

  const ExecuteTransferEvent({
    required this.recipientIdentifier,
    required this.amount,
    required this.pin,
    this.note,
  });

  @override
  List<Object?> get props => [recipientIdentifier, amount, pin, note];
}
