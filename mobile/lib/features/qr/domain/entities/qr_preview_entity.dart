import 'package:equatable/equatable.dart';

class QrPreviewEntity extends Equatable {
  final bool isValid;
  final String validationMessage;
  final String? type;
  final String? recipientWalletId;
  final String? recipientName;
  final String? recipientEmail;
  final double? amount;
  final bool isAmountEditable;
  final String? note;
  final String? referenceCode;

  const QrPreviewEntity({
    required this.isValid,
    required this.validationMessage,
    this.type,
    this.recipientWalletId,
    this.recipientName,
    this.recipientEmail,
    this.amount,
    this.isAmountEditable = true,
    this.note,
    this.referenceCode,
  });

  @override
  List<Object?> get props => [
        isValid,
        validationMessage,
        type,
        recipientWalletId,
        recipientName,
        recipientEmail,
        amount,
        isAmountEditable,
        note,
        referenceCode,
      ];
}
