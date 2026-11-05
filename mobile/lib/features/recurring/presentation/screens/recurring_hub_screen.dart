import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../../data/recurring_remote_datasource.dart';
import '../../data/recurring_repository_impl.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import '../widgets/create_recurring_dialog.dart';

class RecurringHubScreen extends StatelessWidget {
  const RecurringHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecurringBloc(
        repository: RecurringRepositoryImpl(
          remoteDataSource: RecurringRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      )..add(const FetchRecurringEvent()),
      child: const _RecurringHubScreenContent(),
    );
  }
}

class _RecurringHubScreenContent extends StatelessWidget {
  const _RecurringHubScreenContent();

  void _openCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<RecurringBloc>(),
        child: const CreateRecurringDialog(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScheduledPaymentEntity item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Schedule?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to stop scheduled auto-debits for "${item.title}" to ${item.recipientIdentifier}?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep Active', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<RecurringBloc>().add(DeleteRecurringEvent(scheduleId: item.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmExecuteNow(BuildContext context, ScheduledPaymentEntity item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Execute Payment Now?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Trigger immediate transfer of ${CurrencyFormatters.formatPkr(item.amount)} for "${item.title}" without waiting for the next cron cycle?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<RecurringBloc>().add(ExecuteRecurringNowEvent(scheduleId: item.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Execute Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Auto-Pay & Recurring',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _openCreateDialog(context),
              icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 24),
              tooltip: 'New Auto-Debit',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('New Auto-Debit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: (context, state) {
          if (state is RecurringActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is RecurringErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RecurringLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          List<ScheduledPaymentEntity> schedules = [];
          if (state is RecurringLoadedState) {
            schedules = state.schedules;
          } else if (state is RecurringActionSuccessState) {
            schedules = state.schedules;
          } else if (state is RecurringActionLoadingState) {
            schedules = state.currentSchedules;
          } else if (state is RecurringErrorState) {
            schedules = state.cachedSchedules ?? [];
          }

          final activeCount = schedules.where((s) => s.isActive).length;
          final totalOutflow = schedules
              .where((s) => s.isActive)
              .fold(0.0, (sum, item) => sum + item.amount);

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.primary,
            onRefresh: () async {
              context.read<RecurringBloc>().add(const FetchRecurringEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Outflow Banner (Matte Dark Paytin Hero)
                _buildSummaryBanner(activeCount, totalOutflow),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE & SCHEDULED RULES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$activeCount Active',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (schedules.isEmpty)
                  _buildEmptyState(context)
                else
                  ...schedules.map((item) => _buildScheduleCard(context, item)),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBanner(int activeCount, double totalOutflow) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule_send_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Automated Monthly Outflow',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyFormatters.formatPkr(totalOutflow),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Text(
                  '$activeCount',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rules',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8E9584)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, ScheduledPaymentEntity item) {
    final nextDateStr = '${item.nextExecutionDate.day}/${item.nextExecutionDate.month}/${item.nextExecutionDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Frequency + Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.isActive ? AppColors.accent : const Color(0xFFF1F4EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'To: ${item.recipientIdentifier}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatters.formatPkr(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isActive
                          ? AppColors.accent.withOpacity(0.35)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.frequency} • ${item.status}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.isActive ? AppColors.textPrimary : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F4EB), height: 1),
          const SizedBox(height: 12),

          // Row 2: Next Execution Date & Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_repeat_rounded, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Next Execution: $nextDateStr',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                'Ran ${item.executionCount}x',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Action Buttons (Pause/Resume, Execute Now, Delete)
          Row(
            children: [
              // Pause / Resume Toggle
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<RecurringBloc>().add(ToggleRecurringEvent(scheduleId: item.id));
                  },
                  icon: Icon(
                    item.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    item.isActive ? 'Pause' : 'Resume',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E5D7)),
                    backgroundColor: const Color(0xFFF7FAF2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Execute Now (Instant Test)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmExecuteNow(context, item),
                  icon: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.textPrimary),
                  label: const Text('Run Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Delete / Cancel button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _confirmDelete(context, item),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  tooltip: 'Cancel Schedule',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.autorenew_rounded, color: AppColors.textPrimary, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Auto-Debit Schedules',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set up recurring payments for monthly rent, subscriptions, or regular family allowances.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openCreateDialog(context),
              icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.textPrimary),
              label: const Text('Create First Auto-Debit', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}