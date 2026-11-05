import 'package:equatable/equatable.dart';

class SplitParticipantEntity extends Equatable {
  final String id;
  final String userId;
  final String walletTag;
  final String fullName;
  final double amount;
  final String status; // PENDING, PAID, REJECTED
  final DateTime? settledAt;

  const SplitParticipantEntity({
    required this.id,
    required this.userId,
    required this.walletTag,
    required this.fullName,
    required this.amount,
    required this.status,
    this.settledAt,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';

  @override
  List<Object?> get props => [id, userId, walletTag, fullName, amount, status, settledAt];
}
