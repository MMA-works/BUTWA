import 'package:batwa_wallet/features/auth/data/models/user_model.dart';
import 'package:batwa_wallet/features/wallet/data/models/wallet_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final WalletModel wallet;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.wallet,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      wallet: WalletModel.fromJson(json['wallet'] ?? {}),
    );
  }
}
