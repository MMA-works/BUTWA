import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../../data/vaults_remote_datasource.dart';
import '../../data/vaults_repository_impl.dart';
import '../../domain/entities/vault_entity.dart';
import '../bloc/vaults_bloc.dart';
import '../bloc/vaults_event.dart';
import '../bloc/vaults_state.dart';
import '../widgets/create_vault_sheet.dart';
import '../widgets/vault_action_dialog.dart';
import 'create_vault_screen.dart';

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaultsBloc(
        repository: VaultsRepositoryImpl(
          remoteDataSource: VaultsRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      )..add(const FetchVaultsEvent()),
      child: const _VaultsScreenContent(),
    );
  }
}

class _VaultsScreenContent extends StatelessWidget {
  const _VaultsScreenContent();

  Color _parseHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'gadgets':
        return Icons.devices_other_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'emergency':
        return Icons.favorite_rounded;
      case 'hajj':
        return Icons.mosque_rounded;
      case 'wedding':
        return Icons.celebration_rounded;
      case 'savings':
      default:
        return Icons.savings_rounded;
    }
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<VaultsBloc>(),
        child: const CreateVaultSheet(),
      ),
    );
  }

  void _openActionDialog(BuildContext context, VaultEntity vault, bool isDeposit) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<VaultsBloc>(),
        child: VaultActionDialog(vault: vault, isDeposit: isDeposit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Savings Pots & Vaults',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _openCreateSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<VaultsBloc, VaultsState>(
        listener: (context, state) {
          if (state is VaultActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is VaultsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VaultsLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          List<VaultEntity> vaults = [];
          double totalSaved = 0.0;

          if (state is VaultsLoadedState) {
            vaults = state.vaults;
            totalSaved = state.totalSaved;
          } else if (state is VaultActionSuccessState) {
            vaults = state.vaults;
            totalSaved = state.totalSaved;
          } else if (state is VaultActionLoadingState) {
            vaults = state.currentVaults;
            totalSaved = state.totalSaved;
          } else if (state is VaultsErrorState && state.cachedVaults != null) {
            vaults = state.cachedVaults!;
            totalSaved = state.cachedTotalSaved ?? 0.0;
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              context.read<VaultsBloc>().add(const FetchVaultsEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Total Savings Hero Card (Matte Deep Obsidian)
                _buildTotalSavingsHero(context, totalSaved, vaults.length),
                const SizedBox(height: 20),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Target Goals',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        '${vaults.length} Active',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Empty State or List of Vaults
                if (vaults.isEmpty)
                  _buildEmptyState(context)
                else
                  ...vaults.map((vault) => _buildVaultCard(context, vault)),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalSavingsHero(BuildContext context, double totalSaved, int potCount) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.savings_rounded, color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TOTAL VAULT SAVINGS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$potCount Pots Active',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            CurrencyFormatters.formatPkr(totalSaved),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Protected sub-balances segregated from everyday spendings.',
            style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openCreateSheet(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add New Savings Pot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Savings Pots Yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first pot to lock funds for trips, gadgets, or rainy-day emergencies.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _openCreateSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Create First Pot', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultCard(BuildContext context, VaultEntity vault) {
    final potColor = _parseHex(vault.colorHex);
    final iconData = _getIconData(vault.icon);
    final progress = (vault.progressPercentage / 100.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Name + Lock Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: potColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: potColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vault.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (vault.targetDate != null)
                      Text(
                        'Target Date: ${vault.targetDate!.day}/${vault.targetDate!.month}/${vault.targetDate!.year}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
              // Lock Toggle Button
              IconButton(
                onPressed: () {
                  context.read<VaultsBloc>().add(ToggleVaultLockEvent(vaultId: vault.id));
                },
                icon: Icon(
                  vault.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: vault.isLocked ? AppColors.warning : AppColors.textMuted,
                  size: 20,
                ),
                tooltip: vault.isLocked ? 'Strict Lock Active' : 'Unlocked',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amounts & Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SAVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  Text(
                    CurrencyFormatters.formatPkr(vault.currentAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: vault.isCompleted ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  Text(
                    CurrencyFormatters.formatPkr(vault.targetAmount),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(potColor),
            ),
          ),
          const SizedBox(height: 8),

          // Progress percentage & Completion status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${vault.progressPercentage.toStringAsFixed(1)}% completed',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: potColor),
              ),
              if (vault.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Goal Reached!', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Deposit & Withdraw
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openActionDialog(context, vault, false),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 15),
                  label: const Text('Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openActionDialog(context, vault, true),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Deposit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
