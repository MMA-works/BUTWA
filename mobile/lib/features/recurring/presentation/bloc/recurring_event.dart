import 'package:equatable/equatable.dart';

abstract class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecurringEvent extends RecurringEvent {
  const FetchRecurringEvent();
}

class CreateRecurringEvent extends RecurringEvent {
  final String recipientIdentifier;
  final String title;
  final double amount;
  final String frequency;
  final String pin;

  const CreateRecurringEvent({
    required this.recipientIdentifier,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.pin,
  });

  @override
  List<Object?> get props => [recipientIdentifier, title, amount, frequency, pin];
}

class ToggleRecurringEvent extends RecurringEvent {
  final String scheduleId;

  const ToggleRecurringEvent({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}

class DeleteRecurringEvent extends RecurringEvent {
  final String scheduleId;

  const DeleteRecurringEvent({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}

class ExecuteRecurringNowEvent extends RecurringEvent {
  final String scheduleId;

  const ExecuteRecurringNowEvent({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}