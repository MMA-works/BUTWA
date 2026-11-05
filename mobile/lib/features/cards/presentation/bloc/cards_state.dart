import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';

abstract class CardsState extends Equatable {
  const CardsState();

  @override
  List<Object?> get props => [];
}

class CardsInitialState extends CardsState {
  const CardsInitialState();
}

class CardsLoadingState extends CardsState {
  const CardsLoadingState();
}

class CardsLoadedState extends CardsState {
  final List<CardEntity> cards;
  final String? message;

  const CardsLoadedState({required this.cards, this.message});

  @override
  List<Object?> get props => [cards, message];
}

class CardsActionLoadingState extends CardsState {
  final List<CardEntity> cards;

  const CardsActionLoadingState({required this.cards});

  @override
  List<Object?> get props => [cards];
}

class CardsErrorState extends CardsState {
  final String message;
  final List<CardEntity> cards;

  const CardsErrorState({required this.message, this.cards = const []});

  @override
  List<Object?> get props => [message, cards];
}
