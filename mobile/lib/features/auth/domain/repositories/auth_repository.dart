import 'package:batwa_wallet/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String identifier, String password);
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? customTag,
  });
  Future<void> setPin({
    required String pin,
    required String currentPassword,
  });
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}
