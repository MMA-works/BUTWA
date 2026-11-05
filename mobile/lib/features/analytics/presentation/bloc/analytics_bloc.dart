import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AnalyticsBloc({required this.analyticsRepository}) : super(AnalyticsInitial()) {
    on<LoadAnalyticsSummaryEvent>(_onLoadAnalyticsSummary);
    on<SetBudgetEvent>(_onSetBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadAnalyticsSummary(
    LoadAnalyticsSummaryEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final summary = await analyticsRepository.getSummary(period: event.period);
      emit(AnalyticsLoaded(summary: summary));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSetBudget(
    SetBudgetEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      await analyticsRepository.setBudget(
        category: event.category,
        monthlyLimit: event.monthlyLimit,
        monthPeriod: event.monthPeriod,
        alertThresholdPercentage: event.alertThresholdPercentage,
      );
      final summary = await analyticsRepository.getSummary(period: event.monthPeriod);
      emit(AnalyticsLoaded(summary: summary, message: 'Budget limit saved successfully!'));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      await analyticsRepository.deleteBudget(event.budgetId);
      final summary = await analyticsRepository.getSummary(period: event.currentPeriod);
      emit(AnalyticsLoaded(summary: summary, message: 'Budget removed successfully'));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
