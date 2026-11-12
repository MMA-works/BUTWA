import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String walletTag;
  final String currency;
  final double balance;
  final bool isActive;
  final String qrCodeData;

  const WalletEntity({
    required this.id,
    required this.walletTag,
    required this.currency,
    required this.balance,
    required this.isActive,
    required this.qrCodeData,
  });

  @override
  List<Object?> get props => [id, walletTag, currency, balance, isActive, qrCodeData];

  WalletEntity copyWith({
    String? id,
    String? walletTag,
    String? currency,
    double? balance,
    bool? isActive,
    String? qrCodeData,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      walletTag: walletTag ?? this.walletTag,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}
