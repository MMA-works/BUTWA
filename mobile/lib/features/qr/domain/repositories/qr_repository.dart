import '../entities/qr_payload_entity.dart';
import '../entities/qr_preview_entity.dart';

abstract class QrRepository {
  Future<QrPayloadEntity> getMyStaticQrCode();
  Future<QrPayloadEntity> generateDynamicQrCode({
    required double amount,
    String? note,
    int expiryMinutes = 60,
  });
  Future<QrPreviewEntity> parseQrCode(String rawQrData);
  Future<void> payQr({
    required String recipientWalletId,
    required double amount,
    String? note,
    String? referenceCode,
    required String pin,
  });
}
