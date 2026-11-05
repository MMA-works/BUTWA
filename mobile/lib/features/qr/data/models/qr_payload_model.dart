import '../../domain/entities/qr_payload_entity.dart';

class QrPayloadModel extends QrPayloadEntity {
  const QrPayloadModel({
    required super.type,
    required super.walletId,
    required super.accountEmail,
    required super.accountName,
    super.amount,
    super.note,
    super.referenceCode,
    super.expiresAt,
    required super.rawQrData,
  });

  factory QrPayloadModel.fromJson(Map<String, dynamic> json) {
    return QrPayloadModel(
      type: json['type'] as String? ?? 'P2P_STATIC',
      walletId: json['walletId'] as String? ?? '',
      accountEmail: json['accountEmail'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      note: json['note'] as String?,
      referenceCode: json['referenceCode'] as String?,
      expiresAt: json['expiresAt'] as String?,
      rawQrData: json['rawQrData'] as String? ?? '',
    );
  }
}
