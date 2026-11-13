import 'dart:convert';
import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'package:batwa_wallet/core/utils/secure_storage_helper.dart';
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
    final phone = await SecureStorageHelper.getUserPhone() ?? '';
    final tag = await SecureStorageHelper.getWalletTag() ?? '';
    final name = (await SecureStorageHelper.getFullName()) ?? 'BATWA User';
    final email = await SecureStorageHelper.getUserEmail() ?? '';

    final cleanTag = tag.replaceAll(RegExp(r'^@+'), '').trim();
    final bestId = cleanTag.isNotEmpty
        ? cleanTag
        : (phone.isNotEmpty ? phone : (email.isNotEmpty ? email : '03232320829'));

    final displayTag = cleanTag.isNotEmpty ? '@$cleanTag' : (phone.isNotEmpty ? phone : email);

    return QrPayloadModel(
      type: 'P2P_STATIC',
      walletId: bestId,
      accountEmail: displayTag,
      accountName: name.isNotEmpty ? name : 'BATWA User',
      rawQrData: 'BATWA:$bestId',
    );
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
      if (response.data is Map && response.data['success'] == true && response.data['data'] != null) {
        return QrPayloadModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}

    final phone = await SecureStorageHelper.getUserPhone() ?? '03232320829';
    final tag = await SecureStorageHelper.getWalletTag() ?? '@batwa_user';
    final name = (await SecureStorageHelper.getFullName()) ?? 'BATWA User';
    final ref = 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return QrPayloadModel(
      type: 'P2P_DYNAMIC',
      walletId: phone,
      accountEmail: tag,
      accountName: name,
      amount: amount,
      note: note,
      referenceCode: ref,
      rawQrData: 'BATWA:$phone?amount=$amount${note != null && note.isNotEmpty ? '&note=$note' : ''}',
    );
  }

  @override
  Future<QrPreviewModel> parseQrCode(String rawQrData) async {
    // 🌟 Client-Side Instant QR Parsing (no slow/broken /qr/parse network delay)
    String recipient = rawQrData.trim();
    double? suggestedAmount;
    String? note;

    if (recipient.startsWith('BATWA:')) {
      recipient = recipient.replaceFirst('BATWA:', '');
    }

    if (recipient.contains('?')) {
      final parts = recipient.split('?');
      recipient = parts[0];
      final queryParams = Uri.splitQueryString(parts[1]);
      if (queryParams.containsKey('amount')) {
        suggestedAmount = double.tryParse(queryParams['amount'] ?? '');
      }
      if (queryParams.containsKey('note')) {
        note = queryParams['note'];
      }
    }

    if (recipient.startsWith('{') && recipient.endsWith('}')) {
      try {
        final decoded = jsonDecode(recipient);
        if (decoded is Map) {
          recipient = (decoded['walletId'] ?? decoded['recipient'] ?? decoded['accountEmail'] ?? '').toString();
          if (decoded['amount'] != null) {
            suggestedAmount = double.tryParse(decoded['amount'].toString());
          }
          if (decoded['note'] != null) {
            note = decoded['note'].toString();
          }
        }
      } catch (_) {}
    }

    recipient = recipient.replaceAll(RegExp(r'^@+'), '').trim();

    String accountTitle = 'BATWA Verified User';
    if (recipient.isNotEmpty) {
      try {
        final lookupRes = await apiClient.client.get(
          ApiConstants.lookupRecipient,
          queryParameters: {'identifier': recipient},
        );
        if (lookupRes.data is Map && lookupRes.data['data'] != null) {
          accountTitle = lookupRes.data['data']['recipientFullName'] ??
              lookupRes.data['data']['fullName'] ??
              lookupRes.data['data']['accountTitle'] ??
              accountTitle;
        }
      } catch (_) {}
    }

    return QrPreviewModel(
      isValid: recipient.isNotEmpty,
      type: 'P2P_STATIC',
      recipientWalletId: recipient,
      recipientEmail: recipient.startsWith('03') ? recipient : '@$recipient',
      recipientName: accountTitle,
      amount: suggestedAmount,
      note: note,
      validationMessage: recipient.isNotEmpty ? 'Valid BATWA QR Code' : 'Invalid QR Code',
    );
  }

  @override
  Future<void> payQr({
    required String recipientWalletId,
    required double amount,
    String? note,
    String? referenceCode,
    required String pin,
  }) async {
    final phone = await SecureStorageHelper.getUserPhone();
    final tag = await SecureStorageHelper.getWalletTag();
    final sender = (phone != null && phone.isNotEmpty) ? phone : (tag ?? '');

    final response = await apiClient.client.post(
      ApiConstants.transfer,
      data: {
        'senderId': sender,
        'senderPhone': phone ?? sender,
        'sender': sender,
        'recipientIdentifier': recipientWalletId.replaceAll(RegExp(r'^@+'), ''),
        'receiver': recipientWalletId.replaceAll(RegExp(r'^@+'), ''),
        'amount': amount,
        'pin': pin,
        'mpin': pin,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );

    if (response.data is Map && response.data['success'] == false) {
      throw ApiException(message: response.data['message'] ?? 'QR Payment failed');
    }
  }
}
