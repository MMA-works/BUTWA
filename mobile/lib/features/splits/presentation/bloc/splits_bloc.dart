import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import '../../domain/entities/pending_split_entity.dart';
import '../../domain/entities/split_bill_entity.dart';
import '../../domain/repositories/splits_repository.dart';
import 'splits_event.dart';
import 'splits_state.dart';

class SplitsBloc extends Bloc<SplitsEvent, SplitsState> {
  final SplitsRepository repository;

  SplitsBloc({required this.repository}) : super(const SplitsInitialState()) {
    on<FetchSplitsEvent>(_onFetchSplits);
    on<CreateSplitEvent>(_onCreateSplit);
    on<SettleSplitEvent>(_onSettleSplit);
    on<CancelSplitEvent>(_onCancelSplit);
  }

  Future<void> _onFetchSplits(
    FetchSplitsEvent event,
    Emitter<SplitsState> emit,
  ) async {
    emit(const SplitsLoadingState());
    try {
      final created = await repository.getCreatedSplits();
      final pending = await repository.getPendingSplits();
      emit(SplitsLoadedState(
        createdSplits: created,
        pendingSplits: pending,
      ));
    } on ApiException catch (e) {
      emit(SplitsErrorState(errorMessage: e.message));
    } catch (e) {
      emit(SplitsErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateSplit(
    CreateSplitEvent event,
    Emitter<SplitsState> emit,
  ) async {
    final cachedCreated = _getCurrentCreated();
    final cachedPending = _getCurrentPending();

    emit(SplitActionLoadingState(
      currentCreatedSplits: cachedCreated,
      currentPendingSplits: cachedPending,
      actionMessage: 'Creating and sending split requests...',
    ));

    try {
      await repository.createSplitBill(
        title: event.title,
        totalAmount: event.totalAmount,
        note: event.note,
        participantIdentifiers: event.participantIdentifiers,
      );
      final created = await repository.getCreatedSplits();
      final pending = await repository.getPendingSplits();
      emit(SplitActionSuccessState(
        createdSplits: created,
        pendingSplits: pending,
        successMessage: 'Split bill "${event.title}" sent to ${event.participantIdentifiers.length} participants!',
      ));
    } on ApiException catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.message,
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    } catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.toString(),
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    }
  }

  Future<void> _onSettleSplit(
    SettleSplitEvent event,
    Emitter<SplitsState> emit,
  ) async {
    final cachedCreated = _getCurrentCreated();
    final cachedPending = _getCurrentPending();

    emit(SplitActionLoadingState(
      currentCreatedSplits: cachedCreated,
      currentPendingSplits: cachedPending,
      actionMessage: 'Settling split payment...',
    ));

    try {
      await repository.settleSplit(
        splitBillId: event.splitBillId,
        pin: event.pin,
      );
      final created = await repository.getCreatedSplits();
      final pending = await repository.getPendingSplits();
      emit(SplitActionSuccessState(
        createdSplits: created,
        pendingSplits: pending,
        successMessage: 'Split request paid and settled instantly!',
      ));
    } on ApiException catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.message,
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    } catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.toString(),
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    }
  }

  Future<void> _onCancelSplit(
    CancelSplitEvent event,
    Emitter<SplitsState> emit,
  ) async {
    final cachedCreated = _getCurrentCreated();
    final cachedPending = _getCurrentPending();

    try {
      await repository.cancelSplit(event.splitBillId);
      final created = await repository.getCreatedSplits();
      final pending = await repository.getPendingSplits();
      emit(SplitActionSuccessState(
        createdSplits: created,
        pendingSplits: pending,
        successMessage: 'Split bill cancelled.',
      ));
    } on ApiException catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.message,
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    } catch (e) {
      emit(SplitsErrorState(
        errorMessage: e.toString(),
        cachedCreated: cachedCreated,
        cachedPending: cachedPending,
      ));
    }
  }

  List<SplitBillEntity> _getCurrentCreated() {
    if (state is SplitsLoadedState) {
      return (state as SplitsLoadedState).createdSplits;
    } else if (state is SplitActionSuccessState) {
      return (state as SplitActionSuccessState).createdSplits;
    } else if (state is SplitActionLoadingState) {
      return (state as SplitActionLoadingState).currentCreatedSplits;
    } else if (state is SplitsErrorState && (state as SplitsErrorState).cachedCreated != null) {
      return (state as SplitsErrorState).cachedCreated!;
    }
    return [];
  }

  List<PendingSplitEntity> _getCurrentPending() {
    if (state is SplitsLoadedState) {
      return (state as SplitsLoadedState).pendingSplits;
    } else if (state is SplitActionSuccessState) {
      return (state as SplitActionSuccessState).pendingSplits;
    } else if (state is SplitActionLoadingState) {
      return (state as SplitActionLoadingState).currentPendingSplits;
    } else if (state is SplitsErrorState && (state as SplitsErrorState).cachedPending != null) {
      return (state as SplitsErrorState).cachedPending!;
    }
    return [];
  }
}
