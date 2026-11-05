import '../entities/split_bill_entity.dart';
import '../entities/pending_split_entity.dart';

abstract class SplitsRepository {
  Future<List<SplitBillEntity>> getCreatedSplits();
  Future<List<PendingSplitEntity>> getPendingSplits();
  Future<SplitBillEntity> createSplitBill({
    required String title,
    required double totalAmount,
    String? note,
    required List<String> participantIdentifiers,
  });
  Future<void> settleSplit({
    required String splitBillId,
    required String pin,
  });
  Future<void> cancelSplit(String splitBillId);
}
