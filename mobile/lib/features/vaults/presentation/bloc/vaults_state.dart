import 'package:equatable/equatable.dart';
import '../../domain/entities/vault_entity.dart';

abstract class VaultsState extends Equatable {
  const VaultsState();

  @override
  List<Object?> get props => [];
}

class VaultsInitialState extends VaultsState {
  const VaultsInitialState();
}

class VaultsLoadingState extends VaultsState {
  const VaultsLoadingState();
}

class VaultsLoadedState extends VaultsState {
  final List<VaultEntity> vaults;
  final double totalSaved;
  final String? message;

  const VaultsLoadedState({
    required this.vaults,
    required this.totalSaved,
    this.message,
  });

  @override
  List<Object?> get props => [vaults, totalSaved, message];

  VaultsLoadedState copyWith({
    List<VaultEntity>? vaults,
    double? totalSaved,
    String? message,
  }) {
    return VaultsLoadedState(
      vaults: vaults ?? this.vaults,
      totalSaved: totalSaved ?? this.totalSaved,
      message: message,
    );
  }
}

class VaultActionLoadingState extends VaultsState {
  final List<VaultEntity> currentVaults;
  final double totalSaved;
  final String actionMessage;

  const VaultActionLoadingState({
    required this.currentVaults,
    required this.totalSaved,
    required this.actionMessage,
  });

  @override
  List<Object?> get props => [currentVaults, totalSaved, actionMessage];
}

class VaultActionSuccessState extends VaultsState {
  final List<VaultEntity> vaults;
  final double totalSaved;
  final String successMessage;

  const VaultActionSuccessState({
    required this.vaults,
    required this.totalSaved,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [vaults, totalSaved, successMessage];
}

class VaultsErrorState extends VaultsState {
  final String errorMessage;
  final List<VaultEntity>? cachedVaults;
  final double? cachedTotalSaved;

  const VaultsErrorState({
    required this.errorMessage,
    this.cachedVaults,
    this.cachedTotalSaved,
  });

  @override
  List<Object?> get props => [errorMessage, cachedVaults, cachedTotalSaved];
}
