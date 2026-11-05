import 'package:equatable/equatable.dart';
import '../../domain/entities/pending_split_entity.dart';
import '../../domain/entities/split_bill_entity.dart';

abstract class SplitsState extends Equatable {
  const SplitsState();

  @override
  List<Object?> get props => [];
}

class SplitsInitialState extends SplitsState {
  const SplitsInitialState();
}

class SplitsLoadingState extends SplitsState {
  const SplitsLoadingState();
}

class SplitsLoadedState extends SplitsState {
  final List<SplitBillEntity> createdSplits;
  final List<PendingSplitEntity> pendingSplits;
  final String? message;

  const SplitsLoadedState({
    required this.createdSplits,
    required this.pendingSplits,
    this.message,
  });

  @override
  List<Object?> get props => [createdSplits, pendingSplits, message];
}

class SplitActionLoadingState extends SplitsState {
  final List<SplitBillEntity> currentCreatedSplits;
  final List<PendingSplitEntity> currentPendingSplits;
  final String actionMessage;

  const SplitActionLoadingState({
    required this.currentCreatedSplits,
    required this.currentPendingSplits,
    required this.actionMessage,
  });

  @override
  List<Object?> get props => [currentCreatedSplits, currentPendingSplits, actionMessage];
}

class SplitActionSuccessState extends SplitsState {
  final List<SplitBillEntity> createdSplits;
  final List<PendingSplitEntity> pendingSplits;
  final String successMessage;

  const SplitActionSuccessState({
    required this.createdSplits,
    required this.pendingSplits,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [createdSplits, pendingSplits, successMessage];
}

class SplitsErrorState extends SplitsState {
  final String errorMessage;
  final List<SplitBillEntity>? cachedCreated;
  final List<PendingSplitEntity>? cachedPending;

  const SplitsErrorState({
    required this.errorMessage,
    this.cachedCreated,
    this.cachedPending,
  });

  @override
  List<Object?> get props => [errorMessage, cachedCreated, cachedPending];
}
