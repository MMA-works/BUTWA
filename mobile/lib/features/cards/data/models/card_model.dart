import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  const CardModel({
    required super.id,
    required super.cardNumber,
    super.fullCardNumber,
    required super.cardHolderName,
    required super.expiryMonth,
    required super.expiryYear,
    super.cvv,
    required super.cardNetwork,
    required super.status,
    required super.isOnlineEnabled,
    required super.isInternationalEnabled,
    required super.monthlyLimit,
    required super.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id']?.toString() ?? '',
      cardNumber: json['cardNumber']?.toString() ?? '',
      fullCardNumber: json['fullCardNumber']?.toString(),
      cardHolderName: json['cardHolderName']?.toString() ?? '',
      expiryMonth: json['expiryMonth']?.toString() ?? '',
      expiryYear: json['expiryYear']?.toString() ?? '',
      cvv: json['cvv']?.toString(),
      cardNetwork: json['cardNetwork']?.toString() ?? 'MASTERCARD_BLACK',
      status: json['status']?.toString() ?? 'ACTIVE',
      isOnlineEnabled: json['isOnlineEnabled'] ?? json['onlineEnabled'] ?? true,
      isInternationalEnabled: json['isInternationalEnabled'] ?? json['internationalEnabled'] ?? false,
      monthlyLimit: (json['monthlyLimit'] is num)
          ? (json['monthlyLimit'] as num).toDouble()
          : double.tryParse(json['monthlyLimit']?.toString() ?? '5000') ?? 5000.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'fullCardNumber': fullCardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardNetwork': cardNetwork,
      'status': status,
      'isOnlineEnabled': isOnlineEnabled,
      'isInternationalEnabled': isInternationalEnabled,
      'monthlyLimit': monthlyLimit,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
