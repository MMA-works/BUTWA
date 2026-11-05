import 'package:equatable/equatable.dart';

abstract class SplitsEvent extends Equatable {
  const SplitsEvent();

  @override
  List<Object?> get props => [];
}

class FetchSplitsEvent extends SplitsEvent {
  const FetchSplitsEvent();
}

class CreateSplitEvent extends SplitsEvent {
  final String title;
  final double totalAmount;
  final String? note;
  final List<String> participantIdentifiers;

  const CreateSplitEvent({
    required this.title,
    required this.totalAmount,
    this.note,
    required this.participantIdentifiers,
  });

  @override
  List<Object?> get props => [title, totalAmount, note, participantIdentifiers];
}

class SettleSplitEvent extends SplitsEvent {
  final String splitBillId;
  final String pin;

  const SettleSplitEvent({
    required this.splitBillId,
    required this.pin,
  });

  @override
  List<Object?> get props => [splitBillId, pin];
}

class CancelSplitEvent extends SplitsEvent {
  final String splitBillId;

  const CancelSplitEvent({required this.splitBillId});

  @override
  List<Object?> get props => [splitBillId];
}
