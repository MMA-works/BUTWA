import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageHelper {
  static const String _keyAccessToken = 'batwa_access_token';
  static const String _keyRefreshToken = 'batwa_refresh_token';
  static const String _keyUserFullName = 'batwa_user_fullname';
  static const String _keyWalletTag = 'batwa_wallet_tag';
  static const String _keyServerUrl = 'batwa_server_url';
  static const String _keyUserPhone = 'batwa_user_phone';
  static const String _keyUserEmail = 'batwa_user_email';
  static const String _keyUserAddress = 'batwa_user_address';
  static const String _keyUserCnic = 'batwa_user_cnic';
  static const String _keyDailyLimit = 'batwa_daily_limit';
  static const String _keyBiometrics = 'batwa_biometrics_enabled';
  static const String _keyCurrency = 'batwa_selected_currency';
  static const String _keyLanguage = 'batwa_selected_language';
  static const String _keyPushAlerts = 'batwa_push_alerts';
  static const String _keySmsAlerts = 'batwa_sms_alerts';
  static const String _keyEmailStatements = 'batwa_email_statements';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> saveServerUrl(String url) async {
    final prefs = await _prefs;
    await prefs.setString(_keyServerUrl, url);
  }

  static Future<String?> getServerUrl() async {
    final prefs = await _prefs;
    return prefs.getString(_keyServerUrl);
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyRefreshToken);
  }

  static Future<void> saveUserDetails({
    required String fullName,
    required String walletTag,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserFullName, fullName);
    await prefs.setString(_keyWalletTag, walletTag);
  }

  static Future<String?> getFullName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserFullName);
  }

  static Future<String?> getWalletTag() async {
    final prefs = await _prefs;
    return prefs.getString(_keyWalletTag);
  }

  static Future<void> saveUserProfile({
    String? phone,
    String? email,
    String? address,
    String? cnic,
  }) async {
    final prefs = await _prefs;
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (address != null) await prefs.setString(_keyUserAddress, address);
    if (cnic != null) await prefs.setString(_keyUserCnic, cnic);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserPhone);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserAddress() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserAddress);
  }

  static Future<String?> getUserCnic() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserCnic);
  }

  static Future<void> saveDailyLimit(double limit) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyDailyLimit, limit);
  }

  static Future<double?> getDailyLimit() async {
    final prefs = await _prefs;
    return prefs.getDouble(_keyDailyLimit);
  }

  static Future<void> saveBiometricsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyBiometrics, enabled);
  }

  static Future<bool> getBiometricsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyBiometrics) ?? true;
  }

  static Future<void> saveCurrencyAndLanguage({String? currency, String? language}) async {
    final prefs = await _prefs;
    if (currency != null) await prefs.setString(_keyCurrency, currency);
    if (language != null) await prefs.setString(_keyLanguage, language);
  }

  static Future<String> getSelectedCurrency() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCurrency) ?? 'PKR (Rs)';
  }

  static Future<String> getSelectedLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLanguage) ?? 'English (US)';
  }

  static Future<void> saveNotificationPreferences({
    bool? pushAlerts,
    bool? smsAlerts,
    bool? emailStatements,
  }) async {
    final prefs = await _prefs;
    if (pushAlerts != null) await prefs.setBool(_keyPushAlerts, pushAlerts);
    if (smsAlerts != null) await prefs.setBool(_keySmsAlerts, smsAlerts);
    if (emailStatements != null) await prefs.setBool(_keyEmailStatements, emailStatements);
  }

  static Future<Map<String, bool>> getNotificationPreferences() async {
    final prefs = await _prefs;
    return {
      'push': prefs.getBool(_keyPushAlerts) ?? true,
      'sms': prefs.getBool(_keySmsAlerts) ?? true,
      'email': prefs.getBool(_keyEmailStatements) ?? true,
    };
  }

  static Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
