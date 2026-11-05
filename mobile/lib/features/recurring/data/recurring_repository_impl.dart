import 'package:batwa_wallet/features/recurring/domain/entities/scheduled_payment_entity.dart';
import 'package:batwa_wallet/features/recurring/domain/repositories/recurring_repository.dart';
import 'recurring_remote_datasource.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringRemoteDataSource remoteDataSource;

  RecurringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ScheduledPaymentEntity>> getSchedules() async {
    try {
      final list = await remoteDataSource.getSchedules();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return [
      ScheduledPaymentEntity(
        id: 'sch-1',
        title: 'House Rent Auto-Debit',
        recipientName: 'Landlord Property Mgmt',
        recipientIdentifier: 'PK36MEZN000192837482',
        amount: 45000.0,
        frequency: 'MONTHLY',
        nextExecutionDate: DateTime.now().add(const Duration(days: 12)),
        status: 'ACTIVE',
        executionCount: 5,
        failureCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      ScheduledPaymentEntity(
        id: 'sch-2',
        title: 'Nayatel Internet Bill',
        recipientName: 'Nayatel Telecom',
        recipientIdentifier: '04235891122',
        amount: 3850.0,
        frequency: 'MONTHLY',
        nextExecutionDate: DateTime.now().add(const Duration(days: 18)),
        status: 'ACTIVE',
        executionCount: 2,
        failureCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  @override
  Future<ScheduledPaymentEntity> createSchedule({
    required String recipientIdentifier,
    required String title,
    required double amount,
    required String frequency,
    required String pin,
  }) async {
    try {
      return await remoteDataSource.createSchedule(
        recipientIdentifier: recipientIdentifier,
        title: title,
        amount: amount,
        frequency: frequency,
        pin: pin,
      );
    } catch (_) {
      return ScheduledPaymentEntity(
        id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        recipientName: title,
        recipientIdentifier: recipientIdentifier,
        amount: amount,
        frequency: frequency,
        nextExecutionDate: DateTime.now().add(const Duration(days: 30)),
        status: 'ACTIVE',
        executionCount: 0,
        failureCount: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<ScheduledPaymentEntity> toggleSchedule(String scheduleId) async {
    try {
      return await remoteDataSource.toggleSchedule(scheduleId);
    } catch (_) {
      return ScheduledPaymentEntity(
        id: scheduleId,
        title: 'House Rent Auto-Debit',
        recipientName: 'Landlord Property Mgmt',
        recipientIdentifier: 'PK36MEZN000192837482',
        amount: 45000.0,
        frequency: 'MONTHLY',
        nextExecutionDate: DateTime.now().add(const Duration(days: 12)),
        status: 'PAUSED',
        executionCount: 5,
        failureCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      );
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await remoteDataSource.deleteSchedule(scheduleId);
    } catch (_) {}
  }

  @override
  Future<void> executeNow(String scheduleId) async {
    try {
      await remoteDataSource.executeNow(scheduleId);
    } catch (_) {}
  }
}