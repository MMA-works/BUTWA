abstract class AnalyticsEvent {
  const AnalyticsEvent();
}

class LoadAnalyticsSummaryEvent extends AnalyticsEvent {
  final String? period;
  const LoadAnalyticsSummaryEvent({this.period});
}

class SetBudgetEvent extends AnalyticsEvent {
  final String category;
  final double monthlyLimit;
  final String? monthPeriod;
  final int? alertThresholdPercentage;

  const SetBudgetEvent({
    required this.category,
    required this.monthlyLimit,
    this.monthPeriod,
    this.alertThresholdPercentage,
  });
}

class DeleteBudgetEvent extends AnalyticsEvent {
  final String budgetId;
  final String? currentPeriod;

  const DeleteBudgetEvent({required this.budgetId, this.currentPeriod});
}
