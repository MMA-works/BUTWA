import 'package:equatable/equatable.dart';

class RecipientModel extends Equatable {
  final String walletTag;
  final String recipientFullName;
  final String maskedPhoneNumber;
  final String currency;

  const RecipientModel({
    required this.walletTag,
    required this.recipientFullName,
    required this.maskedPhoneNumber,
    required this.currency,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      walletTag: json['walletTag'] ?? '',
      recipientFullName: json['recipientFullName'] ?? '',
      maskedPhoneNumber: json['maskedPhoneNumber'] ?? '',
      currency: json['currency'] ?? 'USD',
    );
  }

  @override
  List<Object?> get props => [walletTag, recipientFullName, maskedPhoneNumber, currency];
}
