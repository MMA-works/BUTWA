import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/features/cards/data/models/card_model.dart';

abstract class CardsRemoteDataSource {
  Future<CardModel> generateCard(String cardNetwork);
  Future<List<CardModel>> getMyCards();
  Future<CardModel> toggleFreeze(String cardId);
  Future<CardModel> toggleOnline(String cardId);
}

class CardsRemoteDataSourceImpl implements CardsRemoteDataSource {
  final ApiClient apiClient;

  CardsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CardModel> generateCard(String cardNetwork) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.generateCard,
        data: {'cardNetwork': cardNetwork},
      );
      if (response.data['success'] == true) {
        return CardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to generate card');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<List<CardModel>> getMyCards() async {
    try {
      final response = await apiClient.client.get(ApiConstants.myCards);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => CardModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch cards');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<CardModel> toggleFreeze(String cardId) async {
    try {
      final response = await apiClient.client.patch(ApiConstants.freezeCard(cardId));
      if (response.data['success'] == true) {
        return CardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to update card status');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<CardModel> toggleOnline(String cardId) async {
    try {
      final response = await apiClient.client.patch(ApiConstants.toggleOnlineCard(cardId));
      if (response.data['success'] == true) {
        return CardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to update online permissions');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
