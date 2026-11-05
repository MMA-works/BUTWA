import 'package:equatable/equatable.dart';
import '../../domain/entities/security_audit_log_entity.dart';
import '../../domain/entities/security_settings_entity.dart';
import '../../domain/entities/user_session_entity.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitialState extends SecurityState {
  const SecurityInitialState();
}

class SecurityLoadingState extends SecurityState {
  const SecurityLoadingState();
}

class SecurityOverviewLoadedState extends SecurityState {
  final SecuritySettingsEntity settings;
  final List<UserSessionEntity> sessions;
  final List<SecurityAuditLogEntity> auditLogs;

  const SecurityOverviewLoadedState({
    required this.settings,
    required this.sessions,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [settings, sessions, auditLogs];
}

class SecurityActionLoadingState extends SecurityState {
  final SecuritySettingsEntity? currentSettings;
  final List<UserSessionEntity>? currentSessions;
  final List<SecurityAuditLogEntity>? currentLogs;

  const SecurityActionLoadingState({
    this.currentSettings,
    this.currentSessions,
    this.currentLogs,
  });

  @override
  List<Object?> get props => [currentSettings, currentSessions, currentLogs];
}

class SecurityActionSuccessState extends SecurityState {
  final String successMessage;
  final SecuritySettingsEntity settings;
  final List<UserSessionEntity> sessions;
  final List<SecurityAuditLogEntity> auditLogs;

  const SecurityActionSuccessState({
    required this.successMessage,
    required this.settings,
    required this.sessions,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [successMessage, settings, sessions, auditLogs];
}

class SecurityErrorState extends SecurityState {
  final String errorMessage;
  final SecuritySettingsEntity? cachedSettings;
  final List<UserSessionEntity>? cachedSessions;
  final List<SecurityAuditLogEntity>? cachedLogs;

  const SecurityErrorState({
    required this.errorMessage,
    this.cachedSettings,
    this.cachedSessions,
    this.cachedLogs,
  });

  @override
  List<Object?> get props => [errorMessage, cachedSettings, cachedSessions, cachedLogs];
}