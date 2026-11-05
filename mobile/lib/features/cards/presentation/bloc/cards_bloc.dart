import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/cards_repository.dart';
import 'cards_event.dart';
import 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  final CardsRepository repository;

  CardsBloc({required this.repository}) : super(const CardsInitialState()) {
    on<FetchCardsEvent>(_onFetchCards);
    on<GenerateCardEvent>(_onGenerateCard);
    on<ToggleFreezeEvent>(_onToggleFreeze);
    on<ToggleOnlineEvent>(_onToggleOnline);
  }

  Future<void> _onFetchCards(
    FetchCardsEvent event,
    Emitter<CardsState> emit,
  ) async {
    emit(const CardsLoadingState());
    try {
      final cards = await repository.getMyCards();
      emit(CardsLoadedState(cards: cards));
    } catch (e) {
      emit(CardsErrorState(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGenerateCard(
    GenerateCardEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentCards = _getCurrentCards();
    emit(CardsActionLoadingState(cards: currentCards));
    try {
      await repository.generateCard(cardNetwork: event.cardNetwork);
      final updatedCards = await repository.getMyCards();
      emit(CardsLoadedState(
        cards: updatedCards,
        message: 'New virtual card issued successfully!',
      ));
    } catch (e) {
      emit(CardsErrorState(
        message: e.toString().replaceAll('Exception: ', ''),
        cards: currentCards,
      ));
    }
  }

  Future<void> _onToggleFreeze(
    ToggleFreezeEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentCards = _getCurrentCards();
    emit(CardsActionLoadingState(cards: currentCards));
    try {
      final updatedCard = await repository.toggleFreeze(event.cardId);
      final updatedList = currentCards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
      emit(CardsLoadedState(
        cards: updatedList,
        message: updatedCard.isFrozen ? 'Card has been frozen.' : 'Card has been un-frozen.',
      ));
    } catch (e) {
      emit(CardsErrorState(
        message: e.toString().replaceAll('Exception: ', ''),
        cards: currentCards,
      ));
    }
  }

  Future<void> _onToggleOnline(
    ToggleOnlineEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentCards = _getCurrentCards();
    emit(CardsActionLoadingState(cards: currentCards));
    try {
      final updatedCard = await repository.toggleOnline(event.cardId);
      final updatedList = currentCards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
      emit(CardsLoadedState(
        cards: updatedList,
        message: updatedCard.isOnlineEnabled ? 'Online transactions enabled.' : 'Online transactions disabled.',
      ));
    } catch (e) {
      emit(CardsErrorState(
        message: e.toString().replaceAll('Exception: ', ''),
        cards: currentCards,
      ));
    }
  }

  List<CardEntity> _getCurrentCards() {
    if (state is CardsLoadedState) {
      return (state as CardsLoadedState).cards;
    } else if (state is CardsActionLoadingState) {
      return (state as CardsActionLoadingState).cards;
    } else if (state is CardsErrorState) {
      return (state as CardsErrorState).cards;
    }
    return [];
  }
}
