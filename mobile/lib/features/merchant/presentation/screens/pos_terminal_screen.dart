import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_bloc.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_event.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_state.dart';

class PosTerminalScreen extends StatefulWidget {
  final String merchantName;

  const PosTerminalScreen({super.key, required this.merchantName});

  @override
  State<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends State<PosTerminalScreen> {
  String _amountString = '0';
  final TextEditingController _noteController = TextEditingController();

  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'C') {
        _amountString = '0';
      } else if (value == '⌫') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (value == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = value;
        } else {
          // Limit decimal places to 2
          if (_amountString.contains('.')) {
            final parts = _amountString.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return;
          }
          if (_amountString.length < 9) {
            _amountString += value;
          }
        }
      }
    });
  }

  void _addQuickAmount(double quick) {
    final current = double.tryParse(_amountString) ?? 0.0;
    final updated = current + quick;
    setState(() {
      _amountString = updated.toStringAsFixed(2);
    });
  }

  void _charge() {
    final amount = double.tryParse(_amountString);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount to charge')),
      );
      return;
    }

    context.read<MerchantBloc>().add(
          CreatePosOrderEvent(
            amount: amount,
            note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
          ),
        );
  }

  void _showPosQrSheet(InvoiceEntity invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PosQrPaymentSheet(invoice: invoice),
    ).then((_) {
      context.read<MerchantBloc>().add(LoadMerchantDashboardEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountString) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Merchant POS Terminal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.merchantName, style: const TextStyle(fontSize: 12, color: AppColors.accent)),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocListener<MerchantBloc, MerchantState>(
        listener: (context, state) {
          if (state is PosOrderCreatedState) {
            _showPosQrSheet(state.invoice);
          } else if (state is MerchantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Amount Display Card
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'TOTAL CHARGE AMOUNT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        child: Text(
                          CurrencyFormatter.format(amount),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Quick note input
                      Container(
                        width: 260,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                        ),
                        child: TextField(
                          controller: _noteController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Order note / Table # (Optional)',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Presets Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildQuickButton(5),
                    const SizedBox(width: 8),
                    _buildQuickButton(10),
                    const SizedBox(width: 8),
                    _buildQuickButton(20),
                    const SizedBox(width: 8),
                    _buildQuickButton(50),
                    const SizedBox(width: 8),
                    _buildQuickButton(100),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Keypad
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildKey('1'),
                            _buildKey('2'),
                            _buildKey('3'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildKey('4'),
                            _buildKey('5'),
                            _buildKey('6'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildKey('7'),
                            _buildKey('8'),
                            _buildKey('9'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildKey('.'),
                            _buildKey('0'),
                            _buildKey('⌫', isSpecial: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Charge Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _charge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          amount > 0 ? 'Charge ${CurrencyFormatter.format(amount)} via QR' : 'Enter Amount to Charge',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(double val) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addQuickAmount(val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Center(
            child: Text(
              '+${val.toInt()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label, {bool isSpecial = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _onKeypadTap(label),
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSpecial ? AppColors.warning : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosQrPaymentSheet extends StatefulWidget {
  final InvoiceEntity invoice;

  const _PosQrPaymentSheet({required this.invoice});

  @override
  State<_PosQrPaymentSheet> createState() => _PosQrPaymentSheetState();
}

class _PosQrPaymentSheetState extends State<_PosQrPaymentSheet> {
  Timer? _pollingTimer;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final repo = context.read<MerchantBloc>().merchantRepository;
        final inv = await repo.getInvoiceByNumber(widget.invoice.invoiceNumber);
        if (inv.status == 'PAID' && mounted) {
          setState(() {
            _isPaid = true;
          });
          _pollingTimer?.cancel();
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (_isPaid) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            const Text(
              'PAYMENT RECEIVED!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
            const SizedBox(height: 6),
            Text(
              'Successfully received ${CurrencyFormatter.format(widget.invoice.grandTotal)}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Next Customer Sale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ] else ...[
            Text(
              'Scan to Pay ${CurrencyFormatter.format(widget.invoice.grandTotal)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Invoice #${widget.invoice.invoiceNumber}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Live Dynamic QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.invoice.qrCodePayload ?? widget.invoice.invoiceNumber,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for customer payment...',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.85)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Close POS Sheet'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
