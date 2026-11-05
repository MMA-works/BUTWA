import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.walletTag,
    required super.currency,
    required super.balance,
    required super.isActive,
    required super.qrCodeData,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    double parsedBalance = 0.0;
    if (json['balance'] != null) {
      if (json['balance'] is num) {
        parsedBalance = (json['balance'] as num).toDouble();
      } else {
        parsedBalance = double.tryParse(json['balance'].toString()) ?? 0.0;
      }
    }

    bool active = true;
    if (json['isActive'] != null) {
      active = json['isActive'] == true;
    } else if (json['active'] != null) {
      active = json['active'] == true;
    }

    return WalletModel(
      id: json['id']?.toString() ?? '',
      walletTag: json['walletTag']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      balance: parsedBalance,
      isActive: active,
      qrCodeData: json['qrCodeData']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletTag': walletTag,
      'currency': currency,
      'balance': balance,
      'isActive': isActive,
      'qrCodeData': qrCodeData,
    };
  }
}
