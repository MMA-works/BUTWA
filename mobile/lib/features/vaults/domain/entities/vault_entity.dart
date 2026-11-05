import 'package:equatable/equatable.dart';

class VaultEntity extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final String icon;
  final String colorHex;
  final DateTime? targetDate;
  final bool isLocked;
  final DateTime createdAt;

  const VaultEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.icon,
    required this.colorHex,
    this.targetDate,
    required this.isLocked,
    required this.createdAt,
  });

  bool get isCompleted => currentAmount >= targetAmount;

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        currentAmount,
        progressPercentage,
        icon,
        colorHex,
        targetDate,
        isLocked,
        createdAt,
      ];
}
