import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

class TransferReceiptScreen extends StatelessWidget {
  final TransactionEntity? transaction;
  final String? recipientName;
  final String? recipientAccount;
  final String? recipientBank;
  final double? amount;
  final String? referenceId;
  final DateTime? dateTime;
  final String? note;
  final VoidCallback? onDone;

  const TransferReceiptScreen({
    super.key,
    this.transaction,
    this.recipientName,
    this.recipientAccount,
    this.recipientBank,
    this.amount,
    this.referenceId,
    this.dateTime,
    this.note,
    this.onDone,
  });

  String _formatAmount(double val) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(val);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedAmount = transaction?.amount ?? amount ?? 5010.0;
    final resolvedRecipient = transaction?.destinationUserFullName.isNotEmpty == true
        ? transaction!.destinationUserFullName
        : (recipientName ?? 'Ahmed Ali');
    final resolvedAccount = recipientAccount ??
        (transaction?.destinationWalletTag.isNotEmpty == true
            ? transaction!.destinationWalletTag
            : '0310-1231234');
    final resolvedBank = recipientBank ?? 'Raast Instant Direct';
    final resolvedRef = transaction?.referenceNumber ?? referenceId ?? 'TXN-976542134';
    final resolvedDate = transaction?.createdAt ?? dateTime ?? DateTime.now();
    final isSuccess = transaction == null || transaction?.status == 'SUCCESS';
    final purpose = note ?? 'Family Support / Personal Transfer';

    final isBatwaInternal = resolvedBank.toLowerCase().contains('batwa') ||
        resolvedAccount.startsWith('@');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF3F5FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onDone ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1B1D28),
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Transaction Receipt',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1B1D28),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  final shareText = '''
━━━━━━━━━━━━━━━━━━━━
💳 BATWA PAYMENT RECEIPT
━━━━━━━━━━━━━━━━━━━━
Status: ${isSuccess ? '✅ SUCCESSFUL' : '❌ FAILED'}
Amount: Rs. ${_formatAmount(resolvedAmount)}
To: $resolvedRecipient
Account/Tag: $resolvedAccount
Bank/Network: $resolvedBank
Reference: $resolvedRef
Date: ${_formatDate(resolvedDate)}
Channel: ${isBatwaInternal ? 'Batwa P2P Ledger' : '1Link / Raast Core'}
━━━━━━━━━━━━━━━━━━━━
Verified by SBP Licensed EMI
''';
                  Clipboard.setData(ClipboardData(text: shareText.trim()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📋 Receipt copied to clipboard for sharing!'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    color: isDark ? Colors.white : const Color(0xFF1B1D28),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🌟 Top Ambient Glow
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.15),
                    const Color(0xFFF3D602).withValues(alpha: isDark ? 0.08 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                  child: Column(
                    children: [
                      // 💳 THE SIGNATURE NEO-BANK VOUCHER CARD
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131722) : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.45)
                                  : const Color(0xFF1B1D28).withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 🌟 Card Top Banner / Success Hero
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              child: Column(
                                children: [
                                  // Triple-Ring Glowing Success Icon
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 68,
                                        height: 68,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        ),
                                      ),
                                      Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF10B981).withValues(alpha: 0.22),
                                        ),
                                      ),
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isSuccess ? Icons.check_rounded : Icons.close_rounded,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // Status Badge Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSuccess
                                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                          : const Color(0xFFEF4444).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSuccess
                                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                            : const Color(0xFFEF4444).withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isSuccess ? 'TRANSFER COMPLETED' : 'TRANSFER FAILED',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.4,
                                            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Big Amount Display
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        'Rs. ',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? const Color(0xFFF3D602) : const Color(0xFFD97706),
                                        ),
                                      ),
                                      Text(
                                        _formatAmount(resolvedAmount),
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.0,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    isBatwaInternal
                                        ? 'Instant Batwa P2P Settlement • 0 Fee'
                                        : 'Raast Real-Time 1Link Core Transfer',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔄 SENDER ➔ RECIPIENT VISUAL PATHWAY
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // From Node
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'FROM',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFF3D602),
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF1B1D28)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  'My Wallet',
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'BATWA Main',
                                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Arrow Pathway
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Color(0xFF10B981),
                                        size: 16,
                                      ),
                                    ),

                                    // To Node
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'TO',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  resolvedRecipient,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isBatwaInternal ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    isBatwaInternal ? Icons.tag_rounded : Icons.account_balance_rounded,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            resolvedBank,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColors.textMuted),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Micro Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(
                                height: 1,
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 📊 SPECIFICATIONS & BREAKDOWN TABLE
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildSpecRow(
                                    label: 'Recipient Account / Tag',
                                    value: resolvedAccount,
                                    isDark: isDark,
                                    badge: isBatwaInternal ? 'Verified User' : '1Link IBAN',
                                    badgeColor: const Color(0xFF10B981),
                                  ),
                                  _buildSpecRow(
                                    label: 'Transaction Reference',
                                    value: resolvedRef,
                                    isDark: isDark,
                                    copyable: true,
                                    context: context,
                                  ),
                                  _buildSpecRow(
                                    label: 'Date & Timestamp',
                                    value: _formatDate(resolvedDate),
                                    isDark: isDark,
                                  ),
                                  _buildSpecRow(
                                    label: 'Payment Purpose',
                                    value: purpose,
                                    isDark: isDark,
                                  ),
                                  _buildSpecRow(
                                    label: 'Transfer Fee',
                                    value: 'Rs. 0.00',
                                    isDark: isDark,
                                    valueColor: const Color(0xFF10B981),
                                    badge: '100% FREE',
                                    badgeColor: const Color(0xFF10B981),
                                  ),
                                  _buildSpecRow(
                                    label: 'Settlement Channel',
                                    value: isBatwaInternal ? 'Batwa P2P Engine' : 'Raast Core (SBP)',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 🛡️ SECURITY BARCODE & SBP REGULATORY SEAL
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF161A26) : const Color(0xFFF1F5F9),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                              ),
                              child: Column(
                                children: [
                                  // Simulated Security Barcode
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(36, (index) {
                                      final isThick = index % 3 == 0 || index % 7 == 0;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        width: isThick ? 2.5 : 1.2,
                                        height: 22,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      );
                                    }),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/payment_networks/raast.png',
                                            height: 14,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
                                          ),
                                          const SizedBox(width: 6),
                                          Image.asset(
                                            'assets/images/payment_networks/1link.png',
                                            height: 10,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          Icon(Icons.shield_rounded, size: 12, color: Color(0xFF10B981)),
                                          SizedBox(width: 4),
                                          Text(
                                            'SBP Licensed EMI • 256-bit Verified',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🚀 BOTTOM ACTION BUTTONS
                      Row(
                        children: [
                          // Download PDF Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.file_download_done_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Expanded(child: Text('Official PDF Receipt downloaded to Downloads.')),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: const Text(
                                'Download PDF',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : const Color(0xFF1B1D28),
                                side: BorderSide(
                                  color: isDark ? Colors.white24 : Colors.black26,
                                  width: 1.2,
                                ),
                                minimumSize: const Size(0, 52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Done Primary Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onDone ?? () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3D602),
                                foregroundColor: const Color(0xFF1B1D28),
                                minimumSize: const Size(0, 52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: const Color(0xFFF3D602).withValues(alpha: 0.35),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper row widget
  Widget _buildSpecRow({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    String? badge,
    Color? badgeColor,
    bool copyable = false,
    BuildContext? context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? const Color(0xFF10B981)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: badgeColor ?? const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: value));
                      if (context != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label copied!'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: isDark ? const Color(0xFFF3D602) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
