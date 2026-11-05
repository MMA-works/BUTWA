import 'package:equatable/equatable.dart';
import 'package:batwa_wallet/features/recurring/domain/entities/scheduled_payment_entity.dart';

abstract class RecurringState extends Equatable {
  const RecurringState();

  @override
  List<Object?> get props => [];
}

class RecurringInitialState extends RecurringState {
  const RecurringInitialState();
}

class RecurringLoadingState extends RecurringState {
  const RecurringLoadingState();
}

class RecurringLoadedState extends RecurringState {
  final List<ScheduledPaymentEntity> schedules;
  final String? message;

  const RecurringLoadedState({
    required this.schedules,
    this.message,
  });

  @override
  List<Object?> get props => [schedules, message];
}

class RecurringActionLoadingState extends RecurringState {
  final List<ScheduledPaymentEntity> currentSchedules;
  final String actionMessage;

  const RecurringActionLoadingState({
    required this.currentSchedules,
    required this.actionMessage,
  });

  @override
  List<Object?> get props => [currentSchedules, actionMessage];
}

class RecurringActionSuccessState extends RecurringState {
  final List<ScheduledPaymentEntity> schedules;
  final String successMessage;

  const RecurringActionSuccessState({
    required this.schedules,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [schedules, successMessage];
}

class RecurringErrorState extends RecurringState {
  final String errorMessage;
  final List<ScheduledPaymentEntity>? cachedSchedules;

  const RecurringErrorState({
    required this.errorMessage,
    this.cachedSchedules,
  });

  @override
  List<Object?> get props => [errorMessage, cachedSchedules];
}