import '../../domain/entities/qr_preview_entity.dart';

class QrPreviewModel extends QrPreviewEntity {
  const QrPreviewModel({
    required super.isValid,
    required super.validationMessage,
    super.type,
    super.recipientWalletId,
    super.recipientName,
    super.recipientEmail,
    super.amount,
    super.isAmountEditable = true,
    super.note,
    super.referenceCode,
  });

  factory QrPreviewModel.fromJson(Map<String, dynamic> json) {
    return QrPreviewModel(
      isValid: json['valid'] as bool? ?? false,
      validationMessage: json['validationMessage'] as String? ?? '',
      type: json['type'] as String?,
      recipientWalletId: json['recipientWalletId'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientEmail: json['recipientEmail'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      isAmountEditable: json['amountEditable'] as bool? ?? true,
      note: json['note'] as String?,
      referenceCode: json['referenceCode'] as String?,
    );
  }
}
