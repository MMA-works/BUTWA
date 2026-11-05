import '../entities/card_entity.dart';

abstract class CardsRepository {
  Future<CardEntity> generateCard({required String cardNetwork});
  Future<List<CardEntity>> getMyCards();
  Future<CardEntity> toggleFreeze(String cardId);
  Future<CardEntity> toggleOnline(String cardId);
}
