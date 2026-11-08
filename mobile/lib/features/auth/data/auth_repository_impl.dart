import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
import 'package:batwa_wallet/features/auth/data/auth_remote_datasource.dart';
import 'package:batwa_wallet/features/auth/domain/entities/user_entity.dart';
import 'package:batwa_wallet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String identifier, String password) async {
    final authData = await remoteDataSource.login(identifier, password);
    ApiClient.setToken(authData.accessToken);
    await SecureStorageHelper.saveTokens(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
    );
    await SecureStorageHelper.saveUserDetails(
      fullName: authData.user.fullName,
      walletTag: authData.wallet.walletTag,
    );
    return authData.user;
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? customTag,
    String? cnicNumber,
  }) async {
    final authData = await remoteDataSource.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      customTag: customTag,
      cnicNumber: cnicNumber,
    );
    ApiClient.setToken(authData.accessToken);
    await SecureStorageHelper.saveTokens(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
    );
    await SecureStorageHelper.saveUserDetails(
      fullName: authData.user.fullName,
      walletTag: authData.wallet.walletTag,
    );
    return authData.user;
  }

  @override
  Future<void> setPin({
    required String pin,
    required String currentPassword,
  }) async {
    await remoteDataSource.setPin(pin: pin, currentPassword: currentPassword);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    ApiClient.setToken(null);
    await SecureStorageHelper.clearTokens();
  }

  @override
  Future<Map<String, dynamic>> sendEmailCode(String email) =>
      remoteDataSource.sendEmailCode(email);

  @override
  Future<bool> verifyEmailCode(String email, String code) =>
      remoteDataSource.verifyEmailCode(email, code);

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) =>
      remoteDataSource.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
}
