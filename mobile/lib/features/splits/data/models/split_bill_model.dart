import '../../domain/entities/split_bill_entity.dart';
import 'split_participant_model.dart';

class SplitBillModel extends SplitBillEntity {
  const SplitBillModel({
    required super.id,
    required super.title,
    required super.totalAmount,
    required super.sharePerPerson,
    super.note,
    required super.status,
    required super.creatorWalletTag,
    required super.creatorName,
    required super.totalParticipants,
    required super.paidParticipants,
    required super.createdAt,
    required super.participants,
  });

  factory SplitBillModel.fromJson(Map<String, dynamic> json) {
    var rawParticipants = json['participants'] as List<dynamic>? ?? [];
    var participantModels = rawParticipants
        .map((p) => SplitParticipantModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final totalAmt = (json['totalAmount'] is num)
        ? (json['totalAmount'] as num).toDouble()
        : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;

    final count = (json['participantsCount'] is num)
        ? (json['participantsCount'] as num).toInt()
        : (json['totalParticipants'] is num)
            ? (json['totalParticipants'] as num).toInt()
            : participantModels.isNotEmpty
                ? participantModels.length
                : 1;

    final share = count > 0 ? (totalAmt / count) : totalAmt;

    return SplitBillModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      totalAmount: totalAmt,
      sharePerPerson: (json['sharePerPerson'] is num)
          ? (json['sharePerPerson'] as num).toDouble()
          : share,
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      creatorWalletTag: json['creatorTag']?.toString() ?? json['creatorWalletTag']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      totalParticipants: count,
      paidParticipants: (json['paidCount'] is num)
          ? (json['paidCount'] as num).toInt()
          : (json['paidParticipants'] is num)
              ? (json['paidParticipants'] as num).toInt()
              : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      participants: participantModels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'sharePerPerson': sharePerPerson,
      'note': note,
      'status': status,
      'creatorWalletTag': creatorWalletTag,
      'creatorName': creatorName,
      'totalParticipants': totalParticipants,
      'paidParticipants': paidParticipants,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants.map((p) => (p as SplitParticipantModel).toJson()).toList(),
    };
  }
}
