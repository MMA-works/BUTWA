import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  bool _isBalanceHidden = false;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<LoadWalletDataEvent>(_onLoadWalletData);
    on<ToggleBalanceVisibilityEvent>(_onToggleBalanceVisibility);
    on<TopUpSubmittedEvent>(_onTopUpSubmitted);
  }

  Future<void> _onLoadWalletData(
    LoadWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) {
      emit(WalletLoading());
    }
    try {
      final results = await Future.wait([
        walletRepository.getMyWallet(),
        walletRepository.getTransactions(page: 0, size: 20),
      ]);

      emit(WalletLoaded(
        wallet: results[0] as WalletEntity,
        transactions: results[1] as List<TransactionEntity>,
        isBalanceHidden: _isBalanceHidden,
      ));
    } catch (e) {
      if (state is! WalletLoaded) {
        emit(WalletError(message: e.toString()));
      }
    }
  }

  void _onToggleBalanceVisibility(
    ToggleBalanceVisibilityEvent event,
    Emitter<WalletState> emit,
  ) {
    _isBalanceHidden = !_isBalanceHidden;
    if (state is WalletLoaded) {
      final current = state as WalletLoaded;
      emit(current.copyWith(isBalanceHidden: _isBalanceHidden));
    }
  }

  Future<void> _onTopUpSubmitted(
    TopUpSubmittedEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(TopUpInProgress());
    try {
      final tx = await walletRepository.topUp(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        description: event.description,
      );
      emit(TopUpSuccess(transaction: tx));
      add(LoadWalletDataEvent());
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }
}
