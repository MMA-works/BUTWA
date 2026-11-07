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
  }) async {
    final authData = await remoteDataSource.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      customTag: customTag,
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
    final token = await SecureStorageHelper.getAccessToken();
    if (token == null || token.isEmpty || token == 'demo_jwt_token_preview') {
      await SecureStorageHelper.clearTokens();
      ApiClient.setToken(null);
      return null;
    }
    ApiClient.setToken(token);
    try {
      final user = await remoteDataSource.getCurrentUser();
      ApiClient.isServerOnline = true;
      return user;
    } catch (_) {
      // Invalidate stale or bad token and return null to show Onboarding / Login
      await SecureStorageHelper.clearTokens();
      ApiClient.setToken(null);
      return null;
    }
  }

  @override
  Future<void> logout() async {
    ApiClient.setToken(null);
    await SecureStorageHelper.clearAll();
  }
}
