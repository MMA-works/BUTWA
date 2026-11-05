import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:batwa_wallet/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:batwa_wallet/features/transfer/presentation/bloc/transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository transferRepository;

  TransferBloc({required this.transferRepository}) : super(TransferInitial()) {
    on<LookupRecipientEvent>(_onLookupRecipient);
    on<ResetRecipientEvent>(_onResetRecipient);
    on<ExecuteTransferEvent>(_onExecuteTransfer);
  }

  Future<void> _onLookupRecipient(
    LookupRecipientEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(RecipientLookupLoading());
    try {
      final recipient = await transferRepository.lookupRecipient(event.identifier);
      emit(RecipientLookupSuccess(recipient: recipient));
    } catch (e) {
      emit(RecipientLookupFailure(message: e.toString()));
    }
  }

  void _onResetRecipient(
    ResetRecipientEvent event,
    Emitter<TransferState> emit,
  ) {
    emit(TransferInitial());
  }

  Future<void> _onExecuteTransfer(
    ExecuteTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransferExecuting());
    try {
      final tx = await transferRepository.executeTransfer(
        recipientIdentifier: event.recipientIdentifier,
        amount: event.amount,
        pin: event.pin,
        note: event.note,
      );
      emit(TransferSuccess(transaction: tx));
    } on ApiException catch (e) {
      int? remainingAttempts;
      if (e.details is Map && e.details['remainingAttempts'] != null) {
        remainingAttempts = e.details['remainingAttempts'];
      }
      emit(TransferFailure(message: e.message, remainingAttempts: remainingAttempts));
    } catch (e) {
      emit(TransferFailure(message: e.toString()));
    }
  }
}
