import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../../data/splits_remote_datasource.dart';
import '../../data/splits_repository_impl.dart';
import '../../domain/entities/pending_split_entity.dart';
import '../../domain/entities/split_bill_entity.dart';
import '../bloc/splits_bloc.dart';
import '../bloc/splits_event.dart';
import '../bloc/splits_state.dart';
import '../widgets/split_settle_dialog.dart';
import 'create_split_screen.dart';

class SplitsHubScreen extends StatelessWidget {
  const SplitsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplitsBloc(
        repository: SplitsRepositoryImpl(
          remoteDataSource: SplitsRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      )..add(const FetchSplitsEvent()),
      child: const _SplitsHubScreenContent(),
    );
  }
}

class _SplitsHubScreenContent extends StatelessWidget {
  const _SplitsHubScreenContent();

  void _openCreateSplit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SplitsBloc>(),
          child: const CreateSplitScreen(),
        ),
      ),
    );
  }

  void _openSettleDialog(BuildContext context, PendingSplitEntity pendingSplit) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SplitsBloc>(),
        child: SplitSettleDialog(pendingSplit: pendingSplit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Split Bills Hub',
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
                onTap: () => _openCreateSplit(context),
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                tabs: const [
                  Tab(text: 'Requests to Pay'),
                  Tab(text: 'My Created Splits'),
                ],
              ),
            ),
          ),
        ),
        body: BlocConsumer<SplitsBloc, SplitsState>(
          listener: (context, state) {
            if (state is SplitActionSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SplitsErrorState) {
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
            if (state is SplitsLoadingState) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            List<PendingSplitEntity> pendingList = [];
            List<SplitBillEntity> createdList = [];

            if (state is SplitsLoadedState) {
              pendingList = state.pendingSplits;
              createdList = state.createdSplits;
            } else if (state is SplitActionSuccessState) {
              pendingList = state.pendingSplits;
              createdList = state.createdSplits;
            } else if (state is SplitActionLoadingState) {
              pendingList = state.currentPendingSplits;
              createdList = state.currentCreatedSplits;
            } else if (state is SplitsErrorState) {
              pendingList = state.cachedPending ?? [];
              createdList = state.cachedCreated ?? [];
            }

            return TabBarView(
              children: [
                // Tab 1: Requests to Pay
                RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    context.read<SplitsBloc>().add(const FetchSplitsEvent());
                  },
                  child: _buildPendingTab(context, pendingList),
                ),

                // Tab 2: My Created Splits
                RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    context.read<SplitsBloc>().add(const FetchSplitsEvent());
                  },
                  child: _buildCreatedTab(context, createdList),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPendingTab(BuildContext context, List<PendingSplitEntity> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'All Caught Up!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have no pending bill requests waiting for payment.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Requested by @${item.creatorWalletTag} (${item.creatorName})',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatters.formatPkr(item.amount),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (item.note != null && item.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: "${item.note}"',
                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openSettleDialog(context, item),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Pay Share with PIN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreatedTab(BuildContext context, List<SplitBillEntity> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_split_rounded, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Created Splits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a split bill to automatically collect payments from friends.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openCreateSplit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Split a Bill Now', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final bill = list[index];
        final progress = (bill.progressPercentage / 100.0).clamp(0.0, 1.0);

        return Container(
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bill.title,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bill.isCompleted
                          ? AppColors.accent.withOpacity(0.3)
                          : AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: bill.isCompleted ? AppColors.primary : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL BILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      Text(
                        CurrencyFormatters.formatPkr(bill.totalAmount),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('SHARE / PERSON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      Text(
                        CurrencyFormatters.formatPkr(bill.sharePerPerson),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bill.isCompleted ? AppColors.primary : AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Progress text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${bill.paidParticipants} of ${bill.totalParticipants} paid (${bill.progressPercentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Participants list
              const Text('PARTICIPANTS STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              ...bill.participants.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            p.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                            size: 15,
                            color: p.isPaid ? AppColors.primary : AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '@${p.walletTag}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Text(
                        p.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: p.isPaid ? AppColors.primary : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
