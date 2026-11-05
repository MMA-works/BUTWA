import 'package:equatable/equatable.dart';
import 'split_participant_entity.dart';

class SplitBillEntity extends Equatable {
  final String id;
  final String title;
  final double totalAmount;
  final double sharePerPerson;
  final String? note;
  final String status; // ACTIVE, COMPLETED, CANCELLED
  final String creatorWalletTag;
  final String creatorName;
  final int totalParticipants;
  final int paidParticipants;
  final DateTime createdAt;
  final List<SplitParticipantEntity> participants;

  const SplitBillEntity({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.sharePerPerson,
    this.note,
    required this.status,
    required this.creatorWalletTag,
    required this.creatorName,
    required this.totalParticipants,
    required this.paidParticipants,
    required this.createdAt,
    required this.participants,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED' || (totalParticipants > 0 && paidParticipants >= totalParticipants);

  double get progressPercentage {
    if (totalParticipants <= 0) return 0.0;
    return (paidParticipants / totalParticipants) * 100.0;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        totalAmount,
        sharePerPerson,
        note,
        status,
        creatorWalletTag,
        creatorName,
        totalParticipants,
        paidParticipants,
        createdAt,
        participants,
      ];
}
