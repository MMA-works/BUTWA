import 'package:equatable/equatable.dart';

class UserSessionEntity extends Equatable {
  final String id;
  final String deviceId;
  final String deviceName;
  final String? osVersion;
  final String? ipAddress;
  final bool isCurrent;
  final DateTime lastActiveAt;
  final DateTime createdAt;

  const UserSessionEntity({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    this.osVersion,
    this.ipAddress,
    required this.isCurrent,
    required this.lastActiveAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, deviceId, deviceName, osVersion, ipAddress, isCurrent, lastActiveAt, createdAt];
}