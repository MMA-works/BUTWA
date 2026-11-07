import 'package:dio/dio.dart';
import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/auth/data/models/auth_response_model.dart';
import 'package:batwa_wallet/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String identifier, String password);
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? customTag,
  });
  Future<void> setPin({required String pin, required String currentPassword});
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  ApiException _handleError(dynamic e) {
    if (e is ApiException) return e;
    if (e is DioException) {
      if (e.error is ApiException) return e.error as ApiException;
      final msg = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString()
          : null;
      return ApiException(
        message: msg ?? e.message ?? 'A network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(message: e.toString().replaceAll('Exception: ', ''));
  }

  @override
  Future<AuthResponseModel> login(String identifier, String password) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.login,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? customTag,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          if (customTag != null && customTag.isNotEmpty) 'customTag': customTag,
        },
      );
      return AuthResponseModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> setPin({required String pin, required String currentPassword}) async {
    try {
      await apiClient.client.post(
        ApiConstants.setPin,
        data: {
          'pin': pin,
          'currentPassword': currentPassword,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.client.get(ApiConstants.currentUser);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
