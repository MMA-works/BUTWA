import 'package:equatable/equatable.dart';

abstract class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCardsEvent extends CardsEvent {
  const FetchCardsEvent();
}

class GenerateCardEvent extends CardsEvent {
  final String cardNetwork;

  const GenerateCardEvent({required this.cardNetwork});

  @override
  List<Object?> get props => [cardNetwork];
}

class ToggleFreezeEvent extends CardsEvent {
  final String cardId;

  const ToggleFreezeEvent({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class ToggleOnlineEvent extends CardsEvent {
  final String cardId;

  const ToggleOnlineEvent({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}
