import '../domain/entities/pending_split_entity.dart';
import '../domain/entities/split_bill_entity.dart';
import '../domain/repositories/splits_repository.dart';
import 'splits_remote_datasource.dart';

class SplitsRepositoryImpl implements SplitsRepository {
  final SplitsRemoteDataSource remoteDataSource;

  SplitsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SplitBillEntity>> getCreatedSplits() async {
    try {
      final list = await remoteDataSource.getCreatedSplits();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return [
      SplitBillEntity(
        id: 'split-1',
        title: 'Friday Dinner at Monal',
        totalAmount: 9600.0,
        sharePerPerson: 2400.0,
        creatorName: 'Muhammad Ali',
        creatorWalletTag: '@mali',
        totalParticipants: 4,
        paidParticipants: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'ACTIVE',
        participants: const [],
      ),
      SplitBillEntity(
        id: 'split-2',
        title: 'Netflix & Spotify Family',
        totalAmount: 3200.0,
        sharePerPerson: 800.0,
        creatorName: 'Muhammad Ali',
        creatorWalletTag: '@mali',
        totalParticipants: 4,
        paidParticipants: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        status: 'SETTLED',
        participants: const [],
      ),
    ];
  }

  @override
  Future<List<PendingSplitEntity>> getPendingSplits() async {
    try {
      final list = await remoteDataSource.getPendingSplits();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return [
      PendingSplitEntity(
        participantId: 'p-1',
        splitBillId: 'psplit-1',
        title: 'Weekend Fuel & Tolls',
        amount: 1250.0,
        creatorName: 'Hamza Tariq',
        creatorWalletTag: '@hamza',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
    ];
  }

  @override
  Future<SplitBillEntity> createSplitBill({
    required String title,
    required double totalAmount,
    String? note,
    required List<String> participantIdentifiers,
  }) async {
    try {
      return await remoteDataSource.createSplitBill(
        title: title,
        totalAmount: totalAmount,
        note: note,
        participantIdentifiers: participantIdentifiers,
      );
    } catch (_) {
      final totalP = participantIdentifiers.length + 1;
      return SplitBillEntity(
        id: 'split-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        totalAmount: totalAmount,
        sharePerPerson: totalAmount / totalP,
        creatorName: 'Muhammad Ali',
        creatorWalletTag: '@mali',
        totalParticipants: totalP,
        paidParticipants: 1,
        createdAt: DateTime.now(),
        status: 'ACTIVE',
        participants: const [],
      );
    }
  }

  @override
  Future<void> settleSplit({
    required String splitBillId,
    required String pin,
  }) async {
    try {
      await remoteDataSource.settleSplit(
        splitBillId: splitBillId,
        pin: pin,
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelSplit(String splitBillId) async {
    try {
      await remoteDataSource.cancelSplit(splitBillId);
    } catch (_) {}
  }
}

