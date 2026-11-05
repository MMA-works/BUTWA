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
        backgroundColor: isDark ? const Color(0xFF051D14) : const Color(0xFF042B1D),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Payment Receipt',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _BillSparklesPainter()),
            ),
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
                                // Success Icon with glow
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
                                            BoxShadow(color: Color(0xFF042B1D), blurRadius: 10, offset: Offset(0, 3)),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 22),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Ticket Card
                                ClipPath(
                                  clipper: const _BillTicketClipper(),
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
                                        // Amount
                                        Text(
                                          'Rs. ${_formatAmount(payment.amountPaid)}',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.6,
                                            color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              'Bill Paid Successfully',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF059669),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 14),

                                        CustomPaint(
                                          size: const Size(double.infinity, 1),
                                          painter: _BillDashedLinePainter(
                                            color: isDark ? Colors.white12 : Colors.black12,
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        _buildRow('Utility Company', payment.companyName, isDark),
                                        const SizedBox(height: 9),
                                        _buildRow('Consumer Name', payment.consumerName, isDark),
                                        const SizedBox(height: 9),
                                        _buildRow('Consumer No.', payment.consumerNumber, isDark),
                                        const SizedBox(height: 9),
                                        _buildRow('Billing Month', payment.billingMonth, isDark),
                                        const SizedBox(height: 9),
                                        _buildRow(
                                          'Date & Time',
                                          DateFormat('dd MMM yyyy, hh:mm a').format(payment.paidAt.toLocal()),
                                          isDark,
                                        ),
                                        const SizedBox(height: 9),
                                        _buildCopyableRow(
                                          context,
                                          'Reference No.',
                                          payment.paymentReference,
                                          isDark,
                                        ),

                                        const SizedBox(height: 14),

                                        // Status badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.22)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Settled instantly via BATWA Wallet • SBP Regulated',
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

                                        CustomPaint(
                                          size: const Size(double.infinity, 1),
                                          painter: _BillDashedLinePainter(
                                            color: isDark ? Colors.white12 : Colors.black12,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

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
                                            Text(
                                              payment.transactionStatus,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF059669),
                                              ),
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

                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Clipboard.setData(ClipboardData(
                                          text:
                                              'BATWA Bill Receipt\nCompany: ${payment.companyName}\nAmount: Rs. ${_formatAmount(payment.amountPaid)}\nConsumer: ${payment.consumerNumber}\nRef: ${payment.paymentReference}\nStatus: ${payment.transactionStatus}',
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
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF3D602),
                                        foregroundColor: const Color(0xFF1B1D28),
                                        minimumSize: const Size(0, 48),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: 3,
                                        shadowColor: const Color(0xFFF3D602).withValues(alpha: 0.4),
                                      ),
                                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
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
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableRow(BuildContext context, String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reference copied!'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Ticket clipper
class _BillTicketClipper extends CustomClipper<Path> {
  const _BillTicketClipper();

  @override
  Path getClip(Size size) {
    const scallopRadius = 6.0;
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
        radius: const Radius.circular(scallopRadius),
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

// Dashed line painter
class _BillDashedLinePainter extends CustomPainter {
  final Color color;
  _BillDashedLinePainter({required this.color});

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

// Sparkles painter
class _BillSparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
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
    drawStar(size.width * 0.88, size.height * 0.05, 5, yellowPaint);
    drawStar(size.width * 0.22, size.height * 0.13, 3.5, yellowPaint);
    drawStar(size.width * 0.80, size.height * 0.15, 4, starPaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.04), 1.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.07), 1.8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
