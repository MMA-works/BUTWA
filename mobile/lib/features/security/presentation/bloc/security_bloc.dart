import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/security_audit_log_entity.dart';
import '../../domain/entities/security_settings_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../domain/repositories/security_repository.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository repository;

  SecurityBloc({required this.repository}) : super(const SecurityInitialState()) {
    on<FetchSecurityOverviewEvent>(_onFetchOverview);
    on<UpdateLimitsEvent>(_onUpdateLimits);
    on<ChangePinEvent>(_onChangePin);
    on<ResetPinEvent>(_onResetPin);
    on<RevokeSessionEvent>(_onRevokeSession);
    on<RevokeOtherSessionsEvent>(_onRevokeOtherSessions);
  }

  SecuritySettingsEntity? _lastSettings;
  List<UserSessionEntity> _lastSessions = [];
  List<SecurityAuditLogEntity> _lastLogs = [];

  Future<void> _onFetchOverview(FetchSecurityOverviewEvent event, Emitter<SecurityState> emit) async {
    emit(const SecurityLoadingState());
    try {
      final settings = await repository.getSecuritySettings();
      final sessions = await repository.getActiveSessions();
      final logs = await repository.getAuditLogs();

      _lastSettings = settings;
      _lastSessions = sessions;
      _lastLogs = logs;

      emit(SecurityOverviewLoadedState(settings: settings, sessions: sessions, auditLogs: logs));
    } catch (e) {
      emit(SecurityErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateLimits(UpdateLimitsEvent event, Emitter<SecurityState> emit) async {
    emit(SecurityActionLoadingState(
      currentSettings: _lastSettings,
      currentSessions: _lastSessions,
      currentLogs: _lastLogs,
    ));

    try {
      final updatedSettings = await repository.updateSecuritySettings(
        dailyLimit: event.dailyLimit,
        monthlyLimit: event.monthlyLimit,
        loginAlerts: event.loginAlerts,
        requirePinForAllTransfers: event.requirePinForAllTransfers,
        pin: event.pin,
      );
      final logs = await repository.getAuditLogs();

      _lastSettings = updatedSettings;
      _lastLogs = logs;

      emit(SecurityActionSuccessState(
        successMessage: 'Spending limits & security preferences updated!',
        settings: updatedSettings,
        sessions: _lastSessions,
        auditLogs: logs,
      ));
    } catch (e) {
      emit(SecurityErrorState(
        errorMessage: e.toString(),
        cachedSettings: _lastSettings,
        cachedSessions: _lastSessions,
        cachedLogs: _lastLogs,
      ));
    }
  }

  Future<void> _onChangePin(ChangePinEvent event, Emitter<SecurityState> emit) async {
    emit(SecurityActionLoadingState(
      currentSettings: _lastSettings,
      currentSessions: _lastSessions,
      currentLogs: _lastLogs,
    ));

    try {
      await repository.changePin(
        currentPinOrPassword: event.currentPinOrPassword,
        newPin: event.newPin,
      );
      final logs = await repository.getAuditLogs();
      _lastLogs = logs;

      emit(SecurityActionSuccessState(
        successMessage: 'Transaction MPIN changed successfully!',
        settings: _lastSettings!,
        sessions: _lastSessions,
        auditLogs: logs,
      ));
    } catch (e) {
      emit(SecurityErrorState(
        errorMessage: e.toString(),
        cachedSettings: _lastSettings,
        cachedSessions: _lastSessions,
        cachedLogs: _lastLogs,
      ));
    }
  }

  Future<void> _onResetPin(ResetPinEvent event, Emitter<SecurityState> emit) async {
    emit(SecurityActionLoadingState(
      currentSettings: _lastSettings,
      currentSessions: _lastSessions,
      currentLogs: _lastLogs,
    ));

    try {
      await repository.resetPin(
        accountPassword: event.accountPassword,
        newPin: event.newPin,
      );
      final logs = await repository.getAuditLogs();
      _lastLogs = logs;

      emit(SecurityActionSuccessState(
        successMessage: 'Transaction MPIN has been reset!',
        settings: _lastSettings!,
        sessions: _lastSessions,
        auditLogs: logs,
      ));
    } catch (e) {
      emit(SecurityErrorState(
        errorMessage: e.toString(),
        cachedSettings: _lastSettings,
        cachedSessions: _lastSessions,
        cachedLogs: _lastLogs,
      ));
    }
  }

  Future<void> _onRevokeSession(RevokeSessionEvent event, Emitter<SecurityState> emit) async {
    try {
      await repository.revokeSession(event.sessionId);
      final sessions = await repository.getActiveSessions();
      final logs = await repository.getAuditLogs();

      _lastSessions = sessions;
      _lastLogs = logs;

      emit(SecurityActionSuccessState(
        successMessage: 'Device session revoked!',
        settings: _lastSettings!,
        sessions: sessions,
        auditLogs: logs,
      ));
    } catch (e) {
      emit(SecurityErrorState(
        errorMessage: e.toString(),
        cachedSettings: _lastSettings,
        cachedSessions: _lastSessions,
        cachedLogs: _lastLogs,
      ));
    }
  }

  Future<void> _onRevokeOtherSessions(RevokeOtherSessionsEvent event, Emitter<SecurityState> emit) async {
    try {
      await repository.revokeOtherSessions();
      final sessions = await repository.getActiveSessions();
      final logs = await repository.getAuditLogs();

      _lastSessions = sessions;
      _lastLogs = logs;

      emit(SecurityActionSuccessState(
        successMessage: 'All other sessions terminated!',
        settings: _lastSettings!,
        sessions: sessions,
        auditLogs: logs,
      ));
    } catch (e) {
      emit(SecurityErrorState(
        errorMessage: e.toString(),
        cachedSettings: _lastSettings,
        cachedSessions: _lastSessions,
        cachedLogs: _lastLogs,
      ));
    }
  }
}