import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';

abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsSummaryEntity summary;
  final String? message;

  const AnalyticsLoaded({required this.summary, this.message});
}

class AnalyticsOperationSuccess extends AnalyticsState {
  final String message;
  const AnalyticsOperationSuccess(this.message);
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
}
