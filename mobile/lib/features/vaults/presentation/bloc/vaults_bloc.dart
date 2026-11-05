import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import '../../domain/entities/vault_entity.dart';
import '../../domain/repositories/vaults_repository.dart';
import 'vaults_event.dart';
import 'vaults_state.dart';

class VaultsBloc extends Bloc<VaultsEvent, VaultsState> {
  final VaultsRepository repository;

  VaultsBloc({required this.repository}) : super(const VaultsInitialState()) {
    on<FetchVaultsEvent>(_onFetchVaults);
    on<CreateVaultEvent>(_onCreateVault);
    on<DepositToVaultEvent>(_onDeposit);
    on<WithdrawFromVaultEvent>(_onWithdraw);
    on<ToggleVaultLockEvent>(_onToggleLock);
  }

  double _calculateTotalSaved(List<VaultEntity> vaults) {
    return vaults.fold(0.0, (sum, v) => sum + v.currentAmount);
  }

  Future<void> _onFetchVaults(
    FetchVaultsEvent event,
    Emitter<VaultsState> emit,
  ) async {
    emit(const VaultsLoadingState());
    try {
      final vaults = await repository.getMyVaults();
      emit(VaultsLoadedState(
        vaults: vaults,
        totalSaved: _calculateTotalSaved(vaults),
      ));
    } on ApiException catch (e) {
      emit(VaultsErrorState(errorMessage: e.message));
    } catch (e) {
      emit(VaultsErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateVault(
    CreateVaultEvent event,
    Emitter<VaultsState> emit,
  ) async {
    final currentVaults = _getCurrentVaults();
    final currentTotal = _calculateTotalSaved(currentVaults);

    emit(VaultActionLoadingState(
      currentVaults: currentVaults,
      totalSaved: currentTotal,
      actionMessage: 'Creating savings pot...',
    ));

    try {
      await repository.createVault(
        name: event.name,
        targetAmount: event.targetAmount,
        icon: event.icon,
        colorHex: event.colorHex,
        targetDate: event.targetDate,
        isLocked: event.isLocked,
      );
      final updatedVaults = await repository.getMyVaults();
      emit(VaultActionSuccessState(
        vaults: updatedVaults,
        totalSaved: _calculateTotalSaved(updatedVaults),
        successMessage: 'Savings Pot "${event.name}" created successfully!',
      ));
    } on ApiException catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.message,
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    } catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.toString(),
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    }
  }

  Future<void> _onDeposit(
    DepositToVaultEvent event,
    Emitter<VaultsState> emit,
  ) async {
    final currentVaults = _getCurrentVaults();
    final currentTotal = _calculateTotalSaved(currentVaults);

    emit(VaultActionLoadingState(
      currentVaults: currentVaults,
      totalSaved: currentTotal,
      actionMessage: 'Depositing into savings pot...',
    ));

    try {
      await repository.deposit(
        vaultId: event.vaultId,
        amount: event.amount,
      );
      final updatedVaults = await repository.getMyVaults();
      emit(VaultActionSuccessState(
        vaults: updatedVaults,
        totalSaved: _calculateTotalSaved(updatedVaults),
        successMessage: 'Successfully added funds to your savings pot!',
      ));
    } on ApiException catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.message,
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    } catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.toString(),
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    }
  }

  Future<void> _onWithdraw(
    WithdrawFromVaultEvent event,
    Emitter<VaultsState> emit,
  ) async {
    final currentVaults = _getCurrentVaults();
    final currentTotal = _calculateTotalSaved(currentVaults);

    emit(VaultActionLoadingState(
      currentVaults: currentVaults,
      totalSaved: currentTotal,
      actionMessage: 'Withdrawing to main wallet...',
    ));

    try {
      await repository.withdraw(
        vaultId: event.vaultId,
        amount: event.amount,
        pin: event.pin,
      );
      final updatedVaults = await repository.getMyVaults();
      emit(VaultActionSuccessState(
        vaults: updatedVaults,
        totalSaved: _calculateTotalSaved(updatedVaults),
        successMessage: 'Funds returned to your main wallet!',
      ));
    } on ApiException catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.message,
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    } catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.toString(),
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    }
  }

  Future<void> _onToggleLock(
    ToggleVaultLockEvent event,
    Emitter<VaultsState> emit,
  ) async {
    final currentVaults = _getCurrentVaults();
    final currentTotal = _calculateTotalSaved(currentVaults);

    try {
      final updated = await repository.toggleLock(event.vaultId);
      final updatedVaults = await repository.getMyVaults();
      final status = updated.isLocked ? "Locked" : "Unlocked";
      emit(VaultActionSuccessState(
        vaults: updatedVaults,
        totalSaved: _calculateTotalSaved(updatedVaults),
        successMessage: 'Savings pot $status!',
      ));
    } on ApiException catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.message,
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    } catch (e) {
      emit(VaultsErrorState(
        errorMessage: e.toString(),
        cachedVaults: currentVaults,
        cachedTotalSaved: currentTotal,
      ));
    }
  }

  List<VaultEntity> _getCurrentVaults() {
    if (state is VaultsLoadedState) {
      return (state as VaultsLoadedState).vaults;
    } else if (state is VaultActionSuccessState) {
      return (state as VaultActionSuccessState).vaults;
    } else if (state is VaultActionLoadingState) {
      return (state as VaultActionLoadingState).currentVaults;
    } else if (state is VaultsErrorState && (state as VaultsErrorState).cachedVaults != null) {
      return (state as VaultsErrorState).cachedVaults!;
    }
    return [];
  }
}
