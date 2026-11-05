import 'package:equatable/equatable.dart';

class SecuritySettingsEntity extends Equatable {
  final String id;
  final double dailySpendingLimit;
  final double monthlySpendingLimit;
  final double todaySpent;
  final double monthSpent;
  final double dailyUsagePercentage;
  final double monthlyUsagePercentage;
  final bool loginAlertsEnabled;
  final bool requirePinForAllTransfers;
  final bool hasPinConfigured;
  final int pinFailedAttempts;
  final bool isAccountLocked;

  const SecuritySettingsEntity({
    required this.id,
    required this.dailySpendingLimit,
    required this.monthlySpendingLimit,
    required this.todaySpent,
    required this.monthSpent,
    required this.dailyUsagePercentage,
    required this.monthlyUsagePercentage,
    required this.loginAlertsEnabled,
    required this.requirePinForAllTransfers,
    required this.hasPinConfigured,
    required this.pinFailedAttempts,
    required this.isAccountLocked,
  });

  @override
  List<Object?> get props => [
        id,
        dailySpendingLimit,
        monthlySpendingLimit,
        todaySpent,
        monthSpent,
        dailyUsagePercentage,
        monthlyUsagePercentage,
        loginAlertsEnabled,
        requirePinForAllTransfers,
        hasPinConfigured,
        pinFailedAttempts,
        isAccountLocked,
      ];
}