import '../entities/security_audit_log_entity.dart';
import '../entities/security_settings_entity.dart';
import '../entities/user_session_entity.dart';

abstract class SecurityRepository {
  Future<SecuritySettingsEntity> getSecuritySettings();
  Future<SecuritySettingsEntity> updateSecuritySettings({
    double? dailyLimit,
    double? monthlyLimit,
    bool? loginAlerts,
    bool? requirePinForAllTransfers,
    required String pin,
  });
  Future<List<UserSessionEntity>> getActiveSessions();
  Future<void> revokeSession(String sessionId);
  Future<void> revokeOtherSessions();
  Future<void> changePin({required String currentPinOrPassword, required String newPin});
  Future<void> resetPin({required String accountPassword, required String newPin});
  Future<List<SecurityAuditLogEntity>> getAuditLogs();
}