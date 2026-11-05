import 'package:batwa_wallet/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.phoneNumber,
    required super.fullName,
    required super.hasPinConfigured,
    required super.isLocked,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      hasPinConfigured: json['hasPinConfigured'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'hasPinConfigured': hasPinConfigured,
      'isLocked': isLocked,
    };
  }
}
