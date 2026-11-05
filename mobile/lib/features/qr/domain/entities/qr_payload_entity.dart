import 'package:equatable/equatable.dart';

class QrPayloadEntity extends Equatable {
  final String type;
  final String walletId;
  final String accountEmail;
  final String accountName;
  final double? amount;
  final String? note;
  final String? referenceCode;
  final String? expiresAt;
  final String rawQrData;

  const QrPayloadEntity({
    required this.type,
    required this.walletId,
    required this.accountEmail,
    required this.accountName,
    this.amount,
    this.note,
    this.referenceCode,
    this.expiresAt,
    required this.rawQrData,
  });

  @override
  List<Object?> get props => [
        type,
        walletId,
        accountEmail,
        accountName,
        amount,
        note,
        referenceCode,
        expiresAt,
        rawQrData,
      ];
}
