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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.client.get(ApiConstants.currentUser);
      return UserModel.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
