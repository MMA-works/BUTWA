import '../entities/vault_entity.dart';

abstract class VaultsRepository {
  Future<List<VaultEntity>> getMyVaults();
  Future<VaultEntity> createVault({
    required String name,
    required double targetAmount,
    String? icon,
    String? colorHex,
    DateTime? targetDate,
    bool isLocked = false,
  });
  Future<VaultEntity> deposit({
    required String vaultId,
    required double amount,
  });
  Future<VaultEntity> withdraw({
    required String vaultId,
    required double amount,
    String? pin,
  });
  Future<VaultEntity> toggleLock(String vaultId);
}
