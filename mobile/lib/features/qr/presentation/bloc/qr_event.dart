import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyQrCodeEvent extends QrEvent {
  const FetchMyQrCodeEvent();
}

class GenerateDynamicQrEvent extends QrEvent {
  final double amount;
  final String? note;
  final int expiryMinutes;

  const GenerateDynamicQrEvent({
    required this.amount,
    this.note,
    this.expiryMinutes = 60,
  });

  @override
  List<Object?> get props => [amount, note, expiryMinutes];
}

class ParseQrCodeEvent extends QrEvent {
  final String rawQrData;

  const ParseQrCodeEvent({required this.rawQrData});

  @override
  List<Object?> get props => [rawQrData];
}

class PayQrEvent extends QrEvent {
  final String recipientWalletId;
  final double amount;
  final String? note;
  final String? referenceCode;
  final String pin;

  const PayQrEvent({
    required this.recipientWalletId,
    required this.amount,
    this.note,
    this.referenceCode,
    required this.pin,
  });

  @override
  List<Object?> get props => [recipientWalletId, amount, note, referenceCode, pin];
}

class ResetQrScanEvent extends QrEvent {
  const ResetQrScanEvent();
}
