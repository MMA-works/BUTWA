import 'package:batwa_wallet/core/constants/api_constants.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/network/api_exception.dart';
import 'models/vault_model.dart';

abstract class VaultsRemoteDataSource {
  Future<List<VaultModel>> getMyVaults();
  Future<VaultModel> createVault({
    required String name,
    required double targetAmount,
    String? icon,
    String? colorHex,
    DateTime? targetDate,
    bool isLocked = false,
  });
  Future<VaultModel> deposit({
    required String vaultId,
    required double amount,
  });
  Future<VaultModel> withdraw({
    required String vaultId,
    required double amount,
    String? pin,
  });
  Future<VaultModel> toggleLock(String vaultId);
}

class VaultsRemoteDataSourceImpl implements VaultsRemoteDataSource {
  final ApiClient apiClient;

  VaultsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VaultModel>> getMyVaults() async {
    try {
      final response = await apiClient.client.get(ApiConstants.vaults);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((json) => VaultModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to fetch vaults');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<VaultModel> createVault({
    required String name,
    required double targetAmount,
    String? icon,
    String? colorHex,
    DateTime? targetDate,
    bool isLocked = false,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.vaults,
        data: {
          'name': name,
          'targetAmount': targetAmount,
          if (icon != null) 'icon': icon,
          if (colorHex != null) 'colorHex': colorHex,
          if (targetDate != null) 'targetDate': targetDate.toIso8601String().split('T')[0],
          'isLocked': isLocked,
        },
      );
      if (response.data['success'] == true) {
        return VaultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to create savings pot');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<VaultModel> deposit({
    required String vaultId,
    required double amount,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.vaultDeposit(vaultId),
        data: {'amount': amount},
      );
      if (response.data['success'] == true) {
        return VaultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to deposit funds');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<VaultModel> withdraw({
    required String vaultId,
    required double amount,
    String? pin,
  }) async {
    try {
      final response = await apiClient.client.post(
        ApiConstants.vaultWithdraw(vaultId),
        data: {
          'amount': amount,
          if (pin != null) 'pin': pin,
        },
      );
      if (response.data['success'] == true) {
        return VaultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to withdraw funds');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<VaultModel> toggleLock(String vaultId) async {
    try {
      final response = await apiClient.client.patch(ApiConstants.vaultToggleLock(vaultId));
      if (response.data['success'] == true) {
        return VaultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw ApiException(message: response.data['message'] ?? 'Failed to update lock status');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
