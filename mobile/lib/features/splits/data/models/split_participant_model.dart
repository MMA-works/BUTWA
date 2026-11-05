import '../../domain/entities/split_participant_entity.dart';

class SplitParticipantModel extends SplitParticipantEntity {
  const SplitParticipantModel({
    required super.id,
    required super.userId,
    required super.walletTag,
    required super.fullName,
    required super.amount,
    required super.status,
    super.settledAt,
  });

  factory SplitParticipantModel.fromJson(Map<String, dynamic> json) {
    return SplitParticipantModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      walletTag: json['walletTag']?.toString() ?? '',
      fullName: json['userFullName']?.toString() ?? json['fullName']?.toString() ?? 'Participant',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      settledAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString())
          : json['settledAt'] != null
              ? DateTime.tryParse(json['settledAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletTag': walletTag,
      'fullName': fullName,
      'amount': amount,
      'status': status,
      'settledAt': settledAt?.toIso8601String(),
    };
  }
}
