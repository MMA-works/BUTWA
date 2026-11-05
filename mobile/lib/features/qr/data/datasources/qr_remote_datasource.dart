import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import '../models/qr_payload_model.dart';
import '../models/qr_preview_model.dart';

abstract class QrRemoteDataSource {
  Future<QrPayloadModel> getMyStaticQrCode();
  Future<QrPayloadModel> generateDynamicQrCode({
    required double amount,
    String? note,
    int expiryMinutes = 60,
  });
  Future<QrPreviewModel> parseQrCode(String rawQrData);
  Future<void> payQr({
    required String recipientWalletId,
    required double amount,
    String? note,
    String? referenceCode,
    required String pin,
  });
}

class QrRemoteDataSourceImpl implements QrRemoteDataSource {
  final ApiClient apiClient;

  QrRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<QrPayloadModel> getMyStaticQrCode() async {
    try {
      final response = await apiClient.client.get(
        ApiConstants.qrMyCode,
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return QrPayloadModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to load QR code');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<QrPayloadModel> generateDynamicQrCode({
    required double amount,
    String? note,
    int expiryMinutes = 60,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.qrGenerateDynamic,
        data: {
          'amount': amount,
          if (note != null && note.isNotEmpty) 'note': note,
          'expiryMinutes': expiryMinutes,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return QrPayloadModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to generate dynamic QR');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<QrPreviewModel> parseQrCode(String rawQrData) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.qrParse,
        data: {
          'rawQrData': rawQrData,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return QrPreviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to parse QR code');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> payQr({
    required String recipientWalletId,
    required double amount,
    String? note,
    String? referenceCode,
    required String pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.qrPay,
        data: {
          'recipientWalletId': recipientWalletId,
          'amount': amount,
          if (note != null && note.isNotEmpty) 'note': note,
          if (referenceCode != null && referenceCode.isNotEmpty) 'referenceCode': referenceCode,
          'pin': pin,
        },
        options: ApiClient.deviceHeaders(),
      );
      if (response.data['success'] == true) {
        return;
      }
      throw ApiException(message: response.data['message'] ?? 'QR Payment failed');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
