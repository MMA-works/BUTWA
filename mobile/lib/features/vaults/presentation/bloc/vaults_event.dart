import 'package:equatable/equatable.dart';

abstract class VaultsEvent extends Equatable {
  const VaultsEvent();

  @override
  List<Object?> get props => [];
}

class FetchVaultsEvent extends VaultsEvent {
  const FetchVaultsEvent();
}

class CreateVaultEvent extends VaultsEvent {
  final String name;
  final double targetAmount;
  final String? icon;
  final String? colorHex;
  final DateTime? targetDate;
  final bool isLocked;

  const CreateVaultEvent({
    required this.name,
    required this.targetAmount,
    this.icon,
    this.colorHex,
    this.targetDate,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [name, targetAmount, icon, colorHex, targetDate, isLocked];
}

class DepositToVaultEvent extends VaultsEvent {
  final String vaultId;
  final double amount;

  const DepositToVaultEvent({
    required this.vaultId,
    required this.amount,
  });

  @override
  List<Object?> get props => [vaultId, amount];
}

class WithdrawFromVaultEvent extends VaultsEvent {
  final String vaultId;
  final double amount;
  final String? pin;

  const WithdrawFromVaultEvent({
    required this.vaultId,
    required this.amount,
    this.pin,
  });

  @override
  List<Object?> get props => [vaultId, amount, pin];
}

class ToggleVaultLockEvent extends VaultsEvent {
  final String vaultId;

  const ToggleVaultLockEvent({required this.vaultId});

  @override
  List<Object?> get props => [vaultId];
}
