import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final String id;
  final String cardNumber;
  final String? fullCardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String? cvv;
  final String cardNetwork;
  final String status;
  final bool isOnlineEnabled;
  final bool isInternationalEnabled;
  final double monthlyLimit;
  final DateTime createdAt;

  const CardEntity({
    required this.id,
    required this.cardNumber,
    this.fullCardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.cvv,
    required this.cardNetwork,
    required this.status,
    required this.isOnlineEnabled,
    required this.isInternationalEnabled,
    required this.monthlyLimit,
    required this.createdAt,
  });

  bool get isFrozen => status.toUpperCase() == 'FROZEN';
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  @override
  List<Object?> get props => [
        id,
        cardNumber,
        fullCardNumber,
        cardHolderName,
        expiryMonth,
        expiryYear,
        cvv,
        cardNetwork,
        status,
        isOnlineEnabled,
        isInternationalEnabled,
        monthlyLimit,
        createdAt,
      ];
}
