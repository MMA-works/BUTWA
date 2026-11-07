import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageHelper {
  static const String _keyAccessToken = 'batwa_access_token';
  static const String _keyRefreshToken = 'batwa_refresh_token';
  static const String _keyUserFullName = 'batwa_user_fullname';
  static const String _keyWalletTag = 'batwa_wallet_tag';
  static const String _keyServerUrl = 'batwa_server_url';

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
