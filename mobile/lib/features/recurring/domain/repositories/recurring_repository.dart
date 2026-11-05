import '../entities/scheduled_payment_entity.dart';

abstract class RecurringRepository {
  Future<List<ScheduledPaymentEntity>> getSchedules();
  Future<ScheduledPaymentEntity> createSchedule({
    required String recipientIdentifier,
    required String title,
    required double amount,
    required String frequency,
    required String pin,
  });
  Future<ScheduledPaymentEntity> toggleSchedule(String scheduleId);
  Future<void> deleteSchedule(String scheduleId);
  Future<void> executeNow(String scheduleId);
}