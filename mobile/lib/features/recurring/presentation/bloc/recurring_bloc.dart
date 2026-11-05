import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:batwa_wallet/features/recurring/domain/entities/scheduled_payment_entity.dart';
import 'recurring_event.dart';
import 'recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringRepository repository;

  RecurringBloc({required this.repository}) : super(const RecurringInitialState()) {
    on<FetchRecurringEvent>(_onFetchRecurring);
    on<CreateRecurringEvent>(_onCreateRecurring);
    on<ToggleRecurringEvent>(_onToggleRecurring);
    on<DeleteRecurringEvent>(_onDeleteRecurring);
    on<ExecuteRecurringNowEvent>(_onExecuteRecurringNow);
  }

  Future<void> _onFetchRecurring(FetchRecurringEvent event, Emitter<RecurringState> emit) async {
    emit(const RecurringLoadingState());
    try {
      final list = await repository.getSchedules();
      emit(RecurringLoadedState(schedules: list));
    } catch (e) {
      emit(RecurringErrorState(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateRecurring(CreateRecurringEvent event, Emitter<RecurringState> emit) async {
    final currentList = _getCurrentSchedules();
    emit(RecurringActionLoadingState(currentSchedules: currentList, actionMessage: 'Creating scheduled payment...'));
    try {
      await repository.createSchedule(
        recipientIdentifier: event.recipientIdentifier,
        title: event.title,
        amount: event.amount,
        frequency: event.frequency,
        pin: event.pin,
      );
      final updatedList = await repository.getSchedules();
      emit(RecurringActionSuccessState(
        schedules: updatedList,
        successMessage: 'Auto-debit schedule for "${event.title}" activated!',
      ));
    } catch (e) {
      emit(RecurringErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        cachedSchedules: currentList,
      ));
    }
  }

  Future<void> _onToggleRecurring(ToggleRecurringEvent event, Emitter<RecurringState> emit) async {
    final currentList = _getCurrentSchedules();
    emit(RecurringActionLoadingState(currentSchedules: currentList, actionMessage: 'Updating schedule status...'));
    try {
      final updated = await repository.toggleSchedule(event.scheduleId);
      final updatedList = await repository.getSchedules();
      final statusLabel = updated.isActive ? 'resumed' : 'paused';
      emit(RecurringActionSuccessState(
        schedules: updatedList,
        successMessage: 'Schedule "${updated.title}" $statusLabel.',
      ));
    } catch (e) {
      emit(RecurringErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        cachedSchedules: currentList,
      ));
    }
  }

  Future<void> _onDeleteRecurring(DeleteRecurringEvent event, Emitter<RecurringState> emit) async {
    final currentList = _getCurrentSchedules();
    emit(RecurringActionLoadingState(currentSchedules: currentList, actionMessage: 'Cancelling schedule...'));
    try {
      await repository.deleteSchedule(event.scheduleId);
      final updatedList = await repository.getSchedules();
      emit(RecurringActionSuccessState(
        schedules: updatedList,
        successMessage: 'Scheduled payment cancelled successfully.',
      ));
    } catch (e) {
      emit(RecurringErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        cachedSchedules: currentList,
      ));
    }
  }

  Future<void> _onExecuteRecurringNow(ExecuteRecurringNowEvent event, Emitter<RecurringState> emit) async {
    final currentList = _getCurrentSchedules();
    emit(RecurringActionLoadingState(currentSchedules: currentList, actionMessage: 'Triggering payment execution...'));
    try {
      await repository.executeNow(event.scheduleId);
      final updatedList = await repository.getSchedules();
      emit(RecurringActionSuccessState(
        schedules: updatedList,
        successMessage: 'Payment executed immediately and ledger updated!',
      ));
    } catch (e) {
      emit(RecurringErrorState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        cachedSchedules: currentList,
      ));
    }
  }

  List<ScheduledPaymentEntity> _getCurrentSchedules() {
    if (state is RecurringLoadedState) {
      return (state as RecurringLoadedState).schedules;
    } else if (state is RecurringActionSuccessState) {
      return (state as RecurringActionSuccessState).schedules;
    } else if (state is RecurringActionLoadingState) {
      return (state as RecurringActionLoadingState).currentSchedules;
    } else if (state is RecurringErrorState && (state as RecurringErrorState).cachedSchedules != null) {
      return (state as RecurringErrorState).cachedSchedules!;
    }
    return [];
  }
}