import 'package:equatable/equatable.dart';

class ScheduledPaymentEntity extends Equatable {
  final String id;
  final String recipientIdentifier;
  final String recipientName;
  final String title;
  final double amount;
  final String frequency; // DAILY, WEEKLY, MONTHLY
  final String status; // ACTIVE, PAUSED, CANCELLED
  final DateTime nextExecutionDate;
  final DateTime? lastExecutionDate;
  final int executionCount;
  final int failureCount;
  final String? lastFailureReason;
  final DateTime createdAt;

  const ScheduledPaymentEntity({
    required this.id,
    required this.recipientIdentifier,
    required this.recipientName,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.nextExecutionDate,
    this.lastExecutionDate,
    required this.executionCount,
    required this.failureCount,
    this.lastFailureReason,
    required this.createdAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isPaused => status.toUpperCase() == 'PAUSED';

  @override
  List<Object?> get props => [
        id,
        recipientIdentifier,
        recipientName,
        title,
        amount,
        frequency,
        status,
        nextExecutionDate,
        lastExecutionDate,
        executionCount,
        failureCount,
        lastFailureReason,
        createdAt,
      ];
}