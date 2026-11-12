import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static String? currentToken;
  static bool isServerOnline = false;

  static void setToken(String? token) {
    currentToken = token;
  }

  static void clearToken() {
    currentToken = null;
  }

  static void updateBaseUrl(String newUrl) {
    ApiConstants.baseUrl = newUrl;
    _instance._dio.options.baseUrl = newUrl;
    SecureStorageHelper.saveServerUrl(newUrl);
  }

  static const String cloudBackendUrl =
      'https://script.google.com/macros/s/AKfycbzoLRzxEdGwLHyxKik_TWyBgnrmMUe7RO3hkn7VIKVh1QApp0x69UIasWYtbJABLnz1/exec';

  static Future<void> initializeServerUrl() async {
    // 1. Sanitize saved URL - remove dead localhosts from physical devices
    String? saved = await SecureStorageHelper.getServerUrl();
    if (saved != null && (saved.contains('127.0.0.1') || saved.contains('10.0.2.2') || saved.contains('172.16.'))) {
      saved = null;
      await SecureStorageHelper.saveServerUrl(cloudBackendUrl);
    }

    // 2. Verified candidate URLs (Cloud first, then local Wi-Fi if running in debug)
    final candidates = [
      cloudBackendUrl,
      ApiConstants.defaultBaseUrl,
      if (saved != null && saved.isNotEmpty) saved,
      'http://192.168.0.105:8080/api/v1',
      if (kDebugMode) 'http://127.0.0.1:8080/api/v1',
      if (kDebugMode) 'http://10.0.2.2:8080/api/v1',
    ].toSet().toList();

    for (final url in candidates) {
      try {
        final probeDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(milliseconds: 6000),
            receiveTimeout: const Duration(milliseconds: 6000),
            followRedirects: true,
          ),
        );
        final pingUrl = url.contains('script.google.com')
            ? '$url?action=ping'
            : '$url/auth/ping';

        final res = await probeDio.get(
          pingUrl,
          options: Options(validateStatus: (status) => status != null),
        );
        if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 400) {
          ApiConstants.baseUrl = url;
          _instance._dio.options.baseUrl = url;
          isServerOnline = true;
          await SecureStorageHelper.saveServerUrl(url);
          return;
        }
      } catch (_) {
        // Probe next candidate
      }
    }

    // Bulletproof default: always lock onto 24/7 Cloud Backend
    ApiConstants.baseUrl = cloudBackendUrl;
    _instance._dio.options.baseUrl = cloudBackendUrl;
    isServerOnline = true;
    await SecureStorageHelper.saveServerUrl(cloudBackendUrl);
  }

  static Options deviceHeaders() => Options(headers: {
        if (!kIsWeb) ...{
          'X-Device-ID': 'INFNX-HOT-10-NUIA',
          'X-Device-Name': 'Infinix HOT 10 Play',
          'X-Device-OS': 'Android 11',
        }
      });

  late final Dio _dio;
  final Uuid _uuid = const Uuid();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = currentToken;
          if (token == null || token.isEmpty) {
            token = await SecureStorageHelper.getAccessToken();
            if (token != null) currentToken = token;
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (!kIsWeb) {
            options.headers['X-Device-ID'] = 'INFNX-HOT-10-NUIA';
            options.headers['X-Device-Name'] = 'Infinix HOT 10 Play';
            options.headers['X-Device-OS'] = 'Android 11';
          }

          // 🌟 Auto-translate for Google Apps Script Web App
          if (options.baseUrl.contains('script.google.com')) {
            final rawPath = options.path.replaceAll(RegExp(r'^/|/$'), '');
            String action = rawPath;
            if (action.startsWith('auth/')) action = action.replaceFirst('auth/', '');
            if (action.startsWith('wallets/')) action = action.replaceFirst('wallets/', '');

            if (action == 'me') action = 'getWallet';
            if (action == 'lookup') action = 'lookup';
            if (action == 'transfer') action = 'transfer';
            if (action == 'transactions') action = 'getTransactions';

            options.path = ''; // Clear path to target /exec directly
            options.queryParameters['action'] = action;

            if (action == 'getWallet' || action == 'getTransactions') {
              if (!options.queryParameters.containsKey('identifier')) {
                final phone = await SecureStorageHelper.getUserPhone();
                final tag = await SecureStorageHelper.getWalletTag();
                final email = await SecureStorageHelper.getUserEmail();
                final id = (phone != null && phone.isNotEmpty)
                    ? phone
                    : (tag != null && tag.isNotEmpty)
                        ? tag
                        : (email != null && email.isNotEmpty)
                            ? email
                            : '';
                if (id.isNotEmpty) {
                  options.queryParameters['identifier'] = id;
                }
              }
            }

            if (options.data is Map<String, dynamic>) {
              final map = options.data as Map<String, dynamic>;
              map['action'] = action;
              if (action == 'transfer') {
                if (!map.containsKey('senderId') || map['senderId'] == null || map['senderId'].toString().isEmpty) {
                  final phone = await SecureStorageHelper.getUserPhone();
                  final tag = await SecureStorageHelper.getWalletTag();
                  final email = await SecureStorageHelper.getUserEmail();
                  final id = (phone != null && phone.isNotEmpty)
                      ? phone
                      : (tag != null && tag.isNotEmpty)
                          ? tag
                          : (email != null && email.isNotEmpty)
                              ? email
                              : '';
                  if (id.isNotEmpty) {
                    map['senderId'] = id;
                    map['senderPhone'] = phone ?? id;
                    map['sender'] = id;
                  }
                }
                if (map.containsKey('recipientIdentifier') && map['recipientIdentifier'] != null) {
                  map['recipientIdentifier'] = map['recipientIdentifier'].toString().replaceAll(RegExp(r'^@+'), '');
                  map['receiver'] = map['recipientIdentifier'];
                  map['receiverQuery'] = map['recipientIdentifier'];
                }
              }
            }
          }

          if (options.method.toUpperCase() == 'POST' &&
              (options.path.contains('/transfer') || options.path.contains('/topup'))) {
            if (!options.headers.containsKey('Idempotency-Key')) {
              options.headers['Idempotency-Key'] = _uuid.v4();
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // 🌟 Handle Google Apps Script 302 Redirect cleanly
          if (response.statusCode == 302 || response.statusCode == 301 || response.statusCode == 307) {
            final location = response.headers.value('location');
            if (location != null && location.isNotEmpty) {
              final cleanDio = Dio(
                BaseOptions(
                  connectTimeout: const Duration(seconds: 20),
                  receiveTimeout: const Duration(seconds: 20),
                ),
              );
              final redirectedRes = await cleanDio.get<dynamic>(location);

              dynamic body = redirectedRes.data;
              if (body is String) {
                try {
                  body = jsonDecode(body);
                } catch (_) {}
              }

              return handler.resolve(
                Response(
                  requestOptions: response.requestOptions,
                  data: body,
                  statusCode: 200,
                  headers: redirectedRes.headers,
                ),
              );
            }
          }

          // Ensure JSON String is parsed to Map
          if (response.data is String) {
            try {
              response.data = jsonDecode(response.data as String);
            } catch (_) {}
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String errorMessage = 'An unexpected network error occurred';
          int? statusCode = e.response?.statusCode;
          dynamic details;

          if (statusCode == 401) {
            currentToken = null;
            SecureStorageHelper.clearTokens();
          }

          if (e.response != null && e.response?.data != null) {
            isServerOnline = true;
            dynamic data = e.response!.data;
            if (data is String) {
              try {
                data = jsonDecode(data);
              } catch (_) {}
            }
            if (data is Map<String, dynamic>) {
              errorMessage = data['message'] ?? errorMessage;
              details = data['data'];
            }
          } else if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            isServerOnline = false;
            errorMessage = 'Connection timed out. Please check your network.';
          } else if (e.type == DioExceptionType.connectionError) {
            isServerOnline = false;
            errorMessage = 'Cannot reach server at ${ApiConstants.baseUrl}.';
          }

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiException(
                message: errorMessage,
                statusCode: statusCode,
                details: details,
              ),
            ),
          );
        },
      ),
    );
  }

  Dio get client => _dio;
}
