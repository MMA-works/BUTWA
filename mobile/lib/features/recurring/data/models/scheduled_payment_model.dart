import 'package:batwa_wallet/features/recurring/domain/entities/scheduled_payment_entity.dart';

class ScheduledPaymentModel extends ScheduledPaymentEntity {
  const ScheduledPaymentModel({
    required super.id,
    required super.recipientIdentifier,
    required super.recipientName,
    required super.title,
    required super.amount,
    required super.frequency,
    required super.status,
    required super.nextExecutionDate,
    super.lastExecutionDate,
    required super.executionCount,
    required super.failureCount,
    super.lastFailureReason,
    required super.createdAt,
  });

  factory ScheduledPaymentModel.fromJson(Map<String, dynamic> json) {
    return ScheduledPaymentModel(
      id: json['id']?.toString() ?? '',
      recipientIdentifier: json['recipientIdentifier']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? json['recipientIdentifier']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      status: json['status']?.toString() ?? 'ACTIVE',
      nextExecutionDate: json['nextExecutionDate'] != null ? DateTime.parse(json['nextExecutionDate'].toString()) : DateTime.now(),
      lastExecutionDate: json['lastExecutionDate'] != null ? DateTime.parse(json['lastExecutionDate'].toString()) : null,
      executionCount: (json['executionCount'] is num) ? (json['executionCount'] as num).toInt() : 0,
      failureCount: (json['failureCount'] is num) ? (json['failureCount'] as num).toInt() : 0,
      lastFailureReason: json['lastFailureReason']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientIdentifier': recipientIdentifier,
      'recipientName': recipientName,
      'title': title,
      'amount': amount,
      'frequency': frequency,
      'status': status,
      'nextExecutionDate': nextExecutionDate.toIso8601String(),
      'lastExecutionDate': lastExecutionDate?.toIso8601String(),
      'executionCount': executionCount,
      'failureCount': failureCount,
      'lastFailureReason': lastFailureReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}