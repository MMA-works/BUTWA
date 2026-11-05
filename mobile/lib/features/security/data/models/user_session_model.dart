import '../../domain/entities/user_session_entity.dart';

class UserSessionModel extends UserSessionEntity {
  const UserSessionModel({
    required super.id,
    required super.deviceId,
    required super.deviceName,
    super.osVersion,
    super.ipAddress,
    required super.isCurrent,
    required super.lastActiveAt,
    required super.createdAt,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? 'Mobile Device',
      osVersion: json['osVersion'] as String?,
      ipAddress: json['ipAddress'] as String?,
      isCurrent: json['isCurrent'] == true || json['current'] == true,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}