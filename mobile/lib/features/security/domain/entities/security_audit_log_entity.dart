import 'package:equatable/equatable.dart';

class SecurityAuditLogEntity extends Equatable {
  final String id;
  final String eventType;
  final String description;
  final String? ipAddress;
  final String? deviceInfo;
  final DateTime timestamp;

  const SecurityAuditLogEntity({
    required this.id,
    required this.eventType,
    required this.description,
    this.ipAddress,
    this.deviceInfo,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, eventType, description, ipAddress, deviceInfo, timestamp];
}