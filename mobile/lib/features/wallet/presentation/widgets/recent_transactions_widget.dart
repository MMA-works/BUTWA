import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/transfer_receipt_screen.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final String currentWalletTag;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.currentWalletTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isCredit = tx.isCreditFor(currentWalletTag);

        IconData txIcon;
        if (tx.transactionType == 'TOPUP') {
          txIcon = Icons.account_balance_rounded;
        } else if (tx.description?.toLowerCase().contains('coffee') == true || tx.description?.toLowerCase().contains('food') == true) {
          txIcon = Icons.store_rounded;
        } else if (isCredit) {
          txIcon = Icons.arrow_downward_rounded;
        } else {
          txIcon = Icons.bolt_rounded;
        }

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransferReceiptScreen(transaction: tx),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Category Icon Badge (Soft rounded squircle)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCredit
                        ? (isDark ? const Color(0xFF00BFA5).withValues(alpha: 0.15) : const Color(0xFFE6F8F5))
                        : (isDark ? AppColors.darkCardBorder : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      txIcon,
                      color: isCredit
                          ? const Color(0xFF00BFA5)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.transactionType == 'TOPUP'
                            ? 'Account Top-Up'
                            : (isCredit
                                ? 'From ${tx.getSenderDisplayTitle()}'
                                : (tx.description != null && tx.description!.isNotEmpty
                                    ? tx.description!
                                    : 'To ${tx.getReceiverDisplayTitle()}')),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatShortDate(tx.createdAt),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '${isCredit ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isCredit
                        ? const Color(0xFF10B981)
                        : (isDark ? const Color(0xFFFF6B6B) : AppColors.error),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
