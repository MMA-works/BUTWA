import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/qr_payload_entity.dart';
import '../../domain/repositories/qr_repository.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final QrRepository qrRepository;

  QrPayloadEntity? _cachedStaticQr;
  QrPayloadEntity? _cachedDynamicQr;

  QrBloc({required this.qrRepository}) : super(const QrInitialState()) {
    on<FetchMyQrCodeEvent>(_onFetchMyQrCode);
    on<GenerateDynamicQrEvent>(_onGenerateDynamicQr);
    on<ParseQrCodeEvent>(_onParseQrCode);
    on<PayQrEvent>(_onPayQr);
    on<ResetQrScanEvent>(_onResetQrScan);
  }

  Future<void> _onFetchMyQrCode(
    FetchMyQrCodeEvent event,
    Emitter<QrState> emit,
  ) async {
    emit(const QrLoadingState());
    try {
      final staticQr = await qrRepository.getMyStaticQrCode();
      _cachedStaticQr = staticQr;
      emit(MyQrLoadedState(
        staticQr: staticQr,
        dynamicQr: _cachedDynamicQr,
      ));
    } catch (e) {
      emit(QrErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onGenerateDynamicQr(
    GenerateDynamicQrEvent event,
    Emitter<QrState> emit,
  ) async {
    emit(const QrLoadingState());
    try {
      final dynamicQr = await qrRepository.generateDynamicQrCode(
        amount: event.amount,
        note: event.note,
        expiryMinutes: event.expiryMinutes,
      );
      _cachedDynamicQr = dynamicQr;

      if (_cachedStaticQr != null) {
        emit(MyQrLoadedState(
          staticQr: _cachedStaticQr!,
          dynamicQr: dynamicQr,
        ));
      } else {
        final staticQr = await qrRepository.getMyStaticQrCode();
        _cachedStaticQr = staticQr;
        emit(MyQrLoadedState(
          staticQr: staticQr,
          dynamicQr: dynamicQr,
        ));
      }
    } catch (e) {
      emit(QrErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onParseQrCode(
    ParseQrCodeEvent event,
    Emitter<QrState> emit,
  ) async {
    emit(const QrLoadingState());
    try {
      final preview = await qrRepository.parseQrCode(event.rawQrData);
      emit(QrParsedState(preview: preview));
    } catch (e) {
      emit(QrErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onPayQr(
    PayQrEvent event,
    Emitter<QrState> emit,
  ) async {
    emit(const QrPaymentProcessingState());
    try {
      await qrRepository.payQr(
        recipientWalletId: event.recipientWalletId,
        amount: event.amount,
        note: event.note,
        referenceCode: event.referenceCode,
        pin: event.pin,
      );
      emit(QrPaymentSuccessState(
        message: 'Payment Successful',
        amount: event.amount,
        recipientName: event.note ?? 'Merchant',
      ));
    } catch (e) {
      emit(QrErrorState(errorMessage: e.toString()));
    }
  }

  void _onResetQrScan(
    ResetQrScanEvent event,
    Emitter<QrState> emit,
  ) {
    emit(const QrInitialState());
  }
}
