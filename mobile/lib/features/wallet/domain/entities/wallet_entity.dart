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
}
