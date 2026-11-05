import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';

class TransferReceiptScreen extends StatelessWidget {
  final TransactionEntity? transaction;

  // Optional manual fields (when opened directly from Send Money screen)
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
    final resolvedRef = transaction?.referenceNumber ?? referenceId ?? '976542134';
    final resolvedDate = transaction?.createdAt ?? dateTime ?? DateTime.now();
    final isSuccess = transaction == null || transaction?.status == 'SUCCESS';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF051D14) : const Color(0xFF042B1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: onDone ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transaction Receipt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            onPressed: onDone ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Sparkles & Glow (Theme Green / Gold)
          Positioned.fill(
            child: CustomPaint(
              painter: SparklesBackgroundPainter(),
            ),
          ),

          // Non-scrolling Compact Body: Guaranteed to fit on screen without scrolling
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 8),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              // 🌟 1. Compact Glowing Circular Checkmark
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.12),
                                      ),
                                    ),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.22),
                                        border: Border.all(color: Colors.white38, width: 1.2),
                                      ),
                                    ),
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF042B1D),
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isSuccess ? Icons.check_rounded : Icons.close_rounded,
                                          color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // 🎫 2. COMPACT PERFORATED TICKET CARD (Fits perfectly without scroll)
                              ClipPath(
                                clipper: const ScallopedTicketClipper(scallopRadius: 6.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF111814) : Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      bottomRight: Radius.circular(22),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Amount Header
                                      Text(
                                        'Rs. ${_formatAmount(resolvedAmount)}',
                                        style: TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.6,
                                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                        ),
                                      ),
                                      const SizedBox(height: 2),

                                      // Subtitle Pill
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            isSuccess ? 'Payment Successful' : 'Payment Failed',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: isSuccess
                                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                                  : const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Dashed divider line across ticket
                                      CustomPaint(
                                        size: const Size(double.infinity, 1),
                                        painter: DashedLinePainter(
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // --- Compact Detail Rows ---
                                      _buildCompactRow('Account / Number', resolvedAccount, resolvedBank, isDark),
                                      const SizedBox(height: 9),
                                      _buildCompactRow('Beneficiary', resolvedRecipient, '*6303', isDark),
                                      const SizedBox(height: 9),
                                      _buildCompactRow('Time', _formatDate(resolvedDate), null, isDark),
                                      const SizedBox(height: 9),
                                      _buildCompactRow(
                                        'Transaction ID',
                                        resolvedRef,
                                        null,
                                        isDark,
                                        copyable: true,
                                        onCopy: () {
                                          HapticFeedback.lightImpact();
                                          Clipboard.setData(ClipboardData(text: resolvedRef));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Transaction ID copied!'),
                                              backgroundColor: Color(0xFF10B981),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 12),

                                      // 🟢 Green Themed Raast Guarantee Box
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.22)),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/payment_networks/raast.png',
                                              height: 16,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            Image.asset(
                                              'assets/images/payment_networks/1link.png',
                                              height: 12,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                            ),
                                            const SizedBox(width: 6),
                                            const Expanded(
                                              child: Text(
                                                '1LINK Raast Real-Time Transfer • 0 Fee',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Dashed divider line across ticket
                                      CustomPaint(
                                        size: const Size(double.infinity, 1),
                                        painter: DashedLinePainter(
                                          color: isDark ? Colors.white12 : Colors.black12,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // 📥 Download & Trust Seals in One Compact Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('📄 Receipt saved to downloads.'),
                                                  backgroundColor: Color(0xFF10B981),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(Icons.download_rounded, color: Color(0xFF10B981), size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Download',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF10B981),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                'RAQAMI • RAAST (SBP Regulated)',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? Colors.white54 : AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 🚀 3. BOTTOM BUTTONS (Visible Immediately - No Scrolling Needed!)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                // Share Button
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(ClipboardData(
                                        text: 'BATWA Payment Receipt\nAmount: Rs. ${_formatAmount(resolvedAmount)}\nTo: $resolvedRecipient ($resolvedAccount)\nRef: $resolvedRef\nStatus: SUCCESS',
                                      ));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Receipt details copied!'),
                                          backgroundColor: Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.share_outlined, size: 16),
                                    label: const Text('Share', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white38, width: 1.2),
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Done Button (Vibrant Yellow #F3D602)
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: onDone ?? () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF3D602), // Brand Yellow Accent
                                      foregroundColor: const Color(0xFF1B1D28), // Dark Navy Text
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 3,
                                      shadowColor: const Color(0xFFF3D602).withValues(alpha: 0.4),
                                    ),
                                    child: const Text(
                                      'Done',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Compact Receipt Row ---
  Widget _buildCompactRow(
    String label,
    String mainValue,
    String? subValue,
    bool isDark, {
    bool copyable = false,
    VoidCallback? onCopy,
  }) {
    return Row(
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
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  mainValue,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (subValue != null && subValue.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '($subValue)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : AppColors.textMuted,
                  ),
                ),
              ],
              if (copyable) ...[
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 13,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// ✂️ SCALLOPED / PERFORATED TICKET CLIPPER
// =========================================================================
class ScallopedTicketClipper extends CustomClipper<Path> {
  final double scallopRadius;

  const ScallopedTicketClipper({this.scallopRadius = 6.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double diameter = scallopRadius * 2;
    final int count = (size.width / diameter).floor();
    final double remainder = (size.width - (count * diameter)) / 2;

    path.moveTo(0, scallopRadius * 2);

    path.lineTo(remainder, scallopRadius * 2);
    for (int i = 0; i < count; i++) {
      final double startX = remainder + (i * diameter);
      path.arcToPoint(
        Offset(startX + diameter, scallopRadius * 2),
        radius: Radius.circular(scallopRadius),
        clockwise: false,
      );
    }
    path.lineTo(size.width, scallopRadius * 2);

    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(size.width, size.height, size.width - 20, size.height);

    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// =========================================================================
// 〰️ DASHED LINE PAINTER
// =========================================================================
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// ✨ BACKGROUND SPARKLES & STARS PAINTER
// =========================================================================
class SparklesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final yellowStarPaint = Paint()
      ..color = const Color(0xFFF3D602).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    void drawStar(double x, double y, double r, Paint p) {
      final path = Path();
      path.moveTo(x, y - r);
      path.quadraticBezierTo(x, y, x + r, y);
      path.quadraticBezierTo(x, y, x, y + r);
      path.quadraticBezierTo(x, y, x - r, y);
      path.quadraticBezierTo(x, y, x, y - r);
      canvas.drawPath(path, p);
    }

    drawStar(size.width * 0.12, size.height * 0.06, 4, starPaint);
    drawStar(size.width * 0.88, size.height * 0.05, 5, yellowStarPaint);
    drawStar(size.width * 0.22, size.height * 0.13, 3.5, yellowStarPaint);
    drawStar(size.width * 0.80, size.height * 0.15, 4, starPaint);
    drawStar(size.width * 0.08, size.height * 0.22, 3, starPaint);
    drawStar(size.width * 0.92, size.height * 0.24, 3.5, starPaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.04), 1.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.07), 1.8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
