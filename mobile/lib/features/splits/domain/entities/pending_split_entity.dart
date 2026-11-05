import 'package:equatable/equatable.dart';

class PendingSplitEntity extends Equatable {
  final String participantId;
  final String splitBillId;
  final String title;
  final String creatorWalletTag;
  final String creatorName;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const PendingSplitEntity({
    required this.participantId,
    required this.splitBillId,
    required this.title,
    required this.creatorWalletTag,
    required this.creatorName,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        participantId,
        splitBillId,
        title,
        creatorWalletTag,
        creatorName,
        amount,
        note,
        createdAt,
      ];
}
