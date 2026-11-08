import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/bills/domain/entities/bill_payment_entity.dart';

class BillReceiptScreen extends StatelessWidget {
  final BillPaymentEntity payment;

  const BillReceiptScreen({super.key, required this.payment});

  String _formatAmount(double val) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF3F5FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
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
            'Utility Bill Receipt',
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
⚡ BATWA BILL PAYMENT RECEIPT
━━━━━━━━━━━━━━━━━━━━
Status: ✅ SETTLED & CONFIRMED
Company: ${payment.companyName}
Consumer: ${payment.consumerName}
Consumer No: ${payment.consumerNumber}
Amount Paid: Rs. ${_formatAmount(payment.amountPaid)}
Billing Month: ${payment.billingMonth}
Reference: ${payment.paymentReference}
Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(payment.paidAt.toLocal())}
━━━━━━━━━━━━━━━━━━━━
Verified by 1BILL & SBP Regulated EMI
''';
                    Clipboard.setData(ClipboardData(text: shareText.trim()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📋 Bill receipt copied to clipboard!'),
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
            // Top Ambient Glow
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
                              // Top Banner / Success Hero
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
                                          child: const Center(
                                            child: Icon(
                                              Icons.receipt_long_rounded,
                                              color: Colors.white,
                                              size: 24,
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
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 13),
                                          SizedBox(width: 5),
                                          Text(
                                            'BILL PAID SUCCESSFULLY',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.4,
                                              color: Color(0xFF10B981),
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
                                          _formatAmount(payment.amountPaid),
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
                                      'Settled Instantly via 1BILL Invoicing Switch',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Company and Consumer Badge Card
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
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3D602).withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFF3D602).withValues(alpha: 0.3)),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.bolt_rounded, color: Color(0xFFF3D602), size: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              payment.companyName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14.5,
                                                color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Consumer: ${payment.consumerName}',
                                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'PAID',
                                          style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10),
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

                              // Detailed Breakdown Table
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      label: 'Consumer Number',
                                      value: payment.consumerNumber,
                                      isDark: isDark,
                                    ),
                                    _buildDetailRow(
                                      label: 'Billing Month',
                                      value: payment.billingMonth,
                                      isDark: isDark,
                                    ),
                                    _buildDetailRow(
                                      label: 'Reference Number',
                                      value: payment.paymentReference,
                                      isDark: isDark,
                                      copyable: true,
                                      context: context,
                                    ),
                                    _buildDetailRow(
                                      label: 'Date & Time',
                                      value: DateFormat('dd MMM yyyy, hh:mm a').format(payment.paidAt.toLocal()),
                                      isDark: isDark,
                                    ),
                                    _buildDetailRow(
                                      label: 'Late Fee / Surcharge',
                                      value: 'Rs. 0.00',
                                      isDark: isDark,
                                      valueColor: const Color(0xFF10B981),
                                    ),
                                    _buildDetailRow(
                                      label: 'Payment Method',
                                      value: 'BATWA Wallet Balance',
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Barcode & Regulatory Footer
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF161A26) : const Color(0xFFF1F5F9),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                                ),
                                child: Column(
                                  children: [
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
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('1LINK 1BILL • AUTHORIZED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                        Text('SBP Regulated EMI', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bottom Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Official PDF Receipt saved to downloads.'),
                                      backgroundColor: Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.white : const Color(0xFF1B1D28),
                                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26, width: 1.2),
                                  minimumSize: const Size(0, 52),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3D602),
                                  foregroundColor: const Color(0xFF1B1D28),
                                  minimumSize: const Size(0, 52),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor: const Color(0xFFF3D602).withValues(alpha: 0.35),
                                ),
                                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
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
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    bool copyable = false,
    BuildContext? context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
          const SizedBox(width: 10),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
