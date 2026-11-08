import 'package:batwa_wallet/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String identifier, String password);
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? customTag,
    String? cnicNumber,
  });
  Future<void> setPin({
    required String pin,
    required String currentPassword,
  });
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();

  Future<Map<String, dynamic>> sendEmailCode(String email);
  Future<bool> verifyEmailCode(String email, String code);
  Future<Map<String, dynamic>> forgotPassword(String email);
  Future<void> resetPassword({required String email, required String code, required String newPassword});
}
