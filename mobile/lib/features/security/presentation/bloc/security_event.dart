import 'package:equatable/equatable.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class FetchSecurityOverviewEvent extends SecurityEvent {
  const FetchSecurityOverviewEvent();
}

class UpdateLimitsEvent extends SecurityEvent {
  final double? dailyLimit;
  final double? monthlyLimit;
  final bool? loginAlerts;
  final bool? requirePinForAllTransfers;
  final String pin;

  const UpdateLimitsEvent({
    this.dailyLimit,
    this.monthlyLimit,
    this.loginAlerts,
    this.requirePinForAllTransfers,
    required this.pin,
  });

  @override
  List<Object?> get props => [dailyLimit, monthlyLimit, loginAlerts, requirePinForAllTransfers, pin];
}

class ChangePinEvent extends SecurityEvent {
  final String currentPinOrPassword;
  final String newPin;

  const ChangePinEvent({required this.currentPinOrPassword, required this.newPin});

  @override
  List<Object?> get props => [currentPinOrPassword, newPin];
}

class ResetPinEvent extends SecurityEvent {
  final String accountPassword;
  final String newPin;

  const ResetPinEvent({required this.accountPassword, required this.newPin});

  @override
  List<Object?> get props => [accountPassword, newPin];
}

class RevokeSessionEvent extends SecurityEvent {
  final String sessionId;

  const RevokeSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class RevokeOtherSessionsEvent extends SecurityEvent {
  const RevokeOtherSessionsEvent();
}