import 'package:equatable/equatable.dart';
import '../../domain/entities/qr_payload_entity.dart';
import '../../domain/entities/qr_preview_entity.dart';

abstract class QrState extends Equatable {
  const QrState();

  @override
  List<Object?> get props => [];
}

class QrInitialState extends QrState {
  const QrInitialState();
}

class QrLoadingState extends QrState {
  const QrLoadingState();
}

class MyQrLoadedState extends QrState {
  final QrPayloadEntity staticQr;
  final QrPayloadEntity? dynamicQr;

  const MyQrLoadedState({
    required this.staticQr,
    this.dynamicQr,
  });

  MyQrLoadedState copyWith({
    QrPayloadEntity? staticQr,
    QrPayloadEntity? dynamicQr,
  }) {
    return MyQrLoadedState(
      staticQr: staticQr ?? this.staticQr,
      dynamicQr: dynamicQr ?? this.dynamicQr,
    );
  }

  @override
  List<Object?> get props => [staticQr, dynamicQr];
}

class QrParsedState extends QrState {
  final QrPreviewEntity preview;

  const QrParsedState({required this.preview});

  @override
  List<Object?> get props => [preview];
}

class QrPaymentProcessingState extends QrState {
  const QrPaymentProcessingState();
}

class QrPaymentSuccessState extends QrState {
  final String message;
  final double amount;
  final String recipientName;

  const QrPaymentSuccessState({
    required this.message,
    required this.amount,
    required this.recipientName,
  });

  @override
  List<Object?> get props => [message, amount, recipientName];
}

class QrErrorState extends QrState {
  final String errorMessage;

  const QrErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
