import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricResult {
  final bool success;
  final String message;
  final String? errorCode;

  const BiometricResult({
    required this.success,
    required this.message,
    this.errorCode,
  });
}

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device hardware supports biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric sensors (e.g. fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticate user using native OS Biometric Prompt
  Future<BiometricResult> authenticate({
    String reason = 'Verify your identity with Biometrics to continue',
    bool biometricOnly = false,
  }) async {
    try {
      final bool available = await isBiometricAvailable();
      if (!available) {
        return const BiometricResult(
          success: false,
          message: 'Biometric authentication is not supported on this device.',
          errorCode: 'NOT_SUPPORTED',
        );
      }

      final bool didAuth = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );

      if (didAuth) {
        return const BiometricResult(
          success: true,
          message: 'Biometric verification successful!',
        );
      } else {
        return const BiometricResult(
          success: false,
          message: 'Biometric verification was cancelled.',
          errorCode: 'USER_CANCELLED',
        );
      }
    } on LocalAuthException catch (e) {
      String userMessage = 'Authentication failed: ${e.description ?? e.code.name}';
      if (e.code == LocalAuthExceptionCode.noBiometricsEnrolled) {
        userMessage = 'No biometric credentials enrolled. Please add a fingerprint in Android Settings.';
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout) {
        userMessage = 'Too many attempts. Biometrics temporarily locked.';
      } else if (e.code == LocalAuthExceptionCode.biometricLockout) {
        userMessage = 'Biometrics locked. Please unlock using your device screen lock PIN.';
      } else if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
        userMessage = 'No device passcode or PIN is set on this phone.';
      } else if (e.code == LocalAuthExceptionCode.userCanceled) {
        userMessage = 'Biometric authentication was cancelled.';
      } else if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        userMessage = 'No biometric sensor detected on this device.';
      }
      return BiometricResult(
        success: false,
        message: userMessage,
        errorCode: e.code.name,
      );
    } on PlatformException catch (e) {
      return BiometricResult(
        success: false,
        message: 'Platform authentication error: ${e.message ?? e.code}',
        errorCode: e.code,
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        message: 'Biometric scan error: $e',
        errorCode: 'UNKNOWN',
      );
    }
  }
}
