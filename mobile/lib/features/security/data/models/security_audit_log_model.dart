import '../../domain/entities/security_audit_log_entity.dart';

class SecurityAuditLogModel extends SecurityAuditLogEntity {
  const SecurityAuditLogModel({
    required super.id,
    required super.eventType,
    required super.description,
    super.ipAddress,
    super.deviceInfo,
    required super.timestamp,
  });

  factory SecurityAuditLogModel.fromJson(Map<String, dynamic> json) {
    return SecurityAuditLogModel(
      id: json['id'] as String,
      eventType: json['eventType'] as String? ?? 'INFO',
      description: json['description'] as String? ?? '',
      ipAddress: json['ipAddress'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}