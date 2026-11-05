import '../../domain/entities/qr_payload_entity.dart';
import '../../domain/entities/qr_preview_entity.dart';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_remote_datasource.dart';

class QrRepositoryImpl implements QrRepository {
  final QrRemoteDataSource remoteDataSource;

  QrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<QrPayloadEntity> getMyStaticQrCode() {
    return remoteDataSource.getMyStaticQrCode();
  }

  @override
  Future<QrPayloadEntity> generateDynamicQrCode({
    required double amount,
    String? note,
    int expiryMinutes = 60,
  }) {
    return remoteDataSource.generateDynamicQrCode(
      amount: amount,
      note: note,
      expiryMinutes: expiryMinutes,
    );
  }

  @override
  Future<QrPreviewEntity> parseQrCode(String rawQrData) {
    return remoteDataSource.parseQrCode(rawQrData);
  }

  @override
  Future<void> payQr({
    required String recipientWalletId,
    required double amount,
    String? note,
    String? referenceCode,
    required String pin,
  }) {
    return remoteDataSource.payQr(
      recipientWalletId: recipientWalletId,
      amount: amount,
      note: note,
      referenceCode: referenceCode,
      pin: pin,
    );
  }
}
