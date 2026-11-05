import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'models/security_audit_log_model.dart';
import 'models/security_settings_model.dart';
import 'models/user_session_model.dart';

abstract class SecurityRemoteDataSource {
  Future<SecuritySettingsModel> getSecuritySettings();
  Future<SecuritySettingsModel> updateSecuritySettings({
    double? dailyLimit,
    double? monthlyLimit,
    bool? loginAlerts,
    bool? requirePinForAllTransfers,
    required String pin,
  });
  Future<List<UserSessionModel>> getActiveSessions();
  Future<void> revokeSession(String sessionId);
  Future<void> revokeOtherSessions();
  Future<void> changePin({required String currentPinOrPassword, required String newPin});
  Future<void> resetPin({required String accountPassword, required String newPin});
  Future<List<SecurityAuditLogModel>> getAuditLogs();
}

class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  final ApiClient apiClient;

  SecurityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SecuritySettingsModel> getSecuritySettings() async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.securitySettings,
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return SecuritySettingsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load security settings');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<SecuritySettingsModel> updateSecuritySettings({
    double? dailyLimit,
    double? monthlyLimit,
    bool? loginAlerts,
    bool? requirePinForAllTransfers,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.put(
        ApiConstants.securitySettings,
        data: {
          if (dailyLimit != null) 'dailySpendingLimit': dailyLimit,
          if (monthlyLimit != null) 'monthlySpendingLimit': monthlyLimit,
          if (loginAlerts != null) 'loginAlertsEnabled': loginAlerts,
          if (requirePinForAllTransfers != null) 'requirePinForAllTransfers': requirePinForAllTransfers,
          'pin': pin,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return SecuritySettingsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to update security settings');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<UserSessionModel>> getActiveSessions() async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.securitySessions,
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => UserSessionModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load active sessions');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    try {
      final response = await apiClient.client.delete(
        ApiConstants.revokeSession(sessionId),
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) return;
      throw ApiException(message: response.data['message'] ?? 'Failed to revoke session');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> revokeOtherSessions() async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.revokeOtherSessions,
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) return;
      throw ApiException(message: response.data['message'] ?? 'Failed to revoke other sessions');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> changePin({required String currentPinOrPassword, required String newPin}) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.changePin,
        data: {
          'currentPinOrPassword': currentPinOrPassword,
          'newPin': newPin,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) return;
      throw ApiException(message: response.data['message'] ?? 'Failed to change PIN');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> resetPin({required String accountPassword, required String newPin}) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.resetPin,
        data: {
          'accountPassword': accountPassword,
          'newPin': newPin,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) return;
      throw ApiException(message: response.data['message'] ?? 'Failed to reset PIN');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<SecurityAuditLogModel>> getAuditLogs() async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.securityAuditLogs,
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => SecurityAuditLogModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load audit logs');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}