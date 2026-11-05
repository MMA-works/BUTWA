import 'package:batwa_wallet/features/vaults/domain/entities/vault_entity.dart';

class VaultModel extends VaultEntity {
  const VaultModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.progressPercentage,
    required super.icon,
    required super.colorHex,
    super.targetDate,
    required super.isLocked,
    required super.createdAt,
  });

  factory VaultModel.fromJson(Map<String, dynamic> json) {
    return VaultModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: (json['targetAmount'] is num)
          ? (json['targetAmount'] as num).toDouble()
          : double.tryParse(json['targetAmount']?.toString() ?? '0') ?? 0.0,
      currentAmount: (json['currentAmount'] is num)
          ? (json['currentAmount'] as num).toDouble()
          : double.tryParse(json['currentAmount']?.toString() ?? '0') ?? 0.0,
      progressPercentage: (json['progressPercentage'] is num)
          ? (json['progressPercentage'] as num).toDouble()
          : double.tryParse(json['progressPercentage']?.toString() ?? '0') ?? 0.0,
      icon: json['icon']?.toString() ?? 'savings',
      colorHex: json['colorHex']?.toString() ?? '#10B981',
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'].toString())
          : null,
      isLocked: json['isLocked'] ?? json['locked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progressPercentage': progressPercentage,
      'icon': icon,
      'colorHex': colorHex,
      'targetDate': targetDate?.toIso8601String(),
      'isLocked': isLocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
