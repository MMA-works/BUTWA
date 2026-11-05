import '../../domain/entities/security_settings_entity.dart';

class SecuritySettingsModel extends SecuritySettingsEntity {
  const SecuritySettingsModel({
    required super.id,
    required super.dailySpendingLimit,
    required super.monthlySpendingLimit,
    required super.todaySpent,
    required super.monthSpent,
    required super.dailyUsagePercentage,
    required super.monthlyUsagePercentage,
    required super.loginAlertsEnabled,
    required super.requirePinForAllTransfers,
    required super.hasPinConfigured,
    required super.pinFailedAttempts,
    required super.isAccountLocked,
  });

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      id: json['id'] as String,
      dailySpendingLimit: (json['dailySpendingLimit'] as num?)?.toDouble() ?? 50000.0,
      monthlySpendingLimit: (json['monthlySpendingLimit'] as num?)?.toDouble() ?? 500000.0,
      todaySpent: (json['todaySpent'] as num?)?.toDouble() ?? 0.0,
      monthSpent: (json['monthSpent'] as num?)?.toDouble() ?? 0.0,
      dailyUsagePercentage: (json['dailyUsagePercentage'] as num?)?.toDouble() ?? 0.0,
      monthlyUsagePercentage: (json['monthlyUsagePercentage'] as num?)?.toDouble() ?? 0.0,
      loginAlertsEnabled: json['loginAlertsEnabled'] as bool? ?? true,
      requirePinForAllTransfers: json['requirePinForAllTransfers'] as bool? ?? true,
      hasPinConfigured: json['hasPinConfigured'] as bool? ?? true,
      pinFailedAttempts: (json['pinFailedAttempts'] as num?)?.toInt() ?? 0,
      isAccountLocked: json['isAccountLocked'] as bool? ?? false,
    );
  }
}