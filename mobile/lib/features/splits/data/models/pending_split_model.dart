import '../../domain/entities/pending_split_entity.dart';

class PendingSplitModel extends PendingSplitEntity {
  const PendingSplitModel({
    required super.participantId,
    required super.splitBillId,
    required super.title,
    required super.creatorWalletTag,
    required super.creatorName,
    required super.amount,
    super.note,
    required super.createdAt,
  });

  factory PendingSplitModel.fromJson(Map<String, dynamic> json) {
    return PendingSplitModel(
      participantId: json['participantId']?.toString() ?? '',
      splitBillId: json['splitBillId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      creatorWalletTag: json['creatorTag']?.toString() ?? json['creatorWalletTag']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      note: json['note']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'splitBillId': splitBillId,
      'title': title,
      'creatorWalletTag': creatorWalletTag,
      'creatorName': creatorName,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
