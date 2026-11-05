import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/merchant/domain/entities/merchant_entities.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_bloc.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_event.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_state.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceEntity invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late InvoiceEntity _invoice;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showPayModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(
              'Pay Invoice #${_invoice.invoiceNumber}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Total Amount: ${CurrencyFormatter.format(_invoice.grandTotal)} to ${_invoice.merchantBusinessName}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text('Enter 4-Digit MPIN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 12, color: AppColors.accent),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_pinController.text.length == 4) {
                    Navigator.pop(ctx);
                    context.read<MerchantBloc>().add(
                          PayInvoiceEvent(
                            invoiceIdentifier: _invoice.invoiceNumber,
                            pin: _pinController.text,
                          ),
                        );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Confirm Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _invoice.status == 'PAID';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Digital Invoice Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocListener<MerchantBloc, MerchantState>(
        listener: (context, state) {
          if (state is InvoicePaidState) {
            setState(() {
              _invoice = state.invoice;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice paid successfully!'), backgroundColor: AppColors.success),
            );
          } else if (state is MerchantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Receipt Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isPaid ? AppColors.success : AppColors.warning).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isPaid ? AppColors.success : AppColors.warning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                              size: 14, color: isPaid ? AppColors.success : AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            isPaid ? 'PAID & SETTLED' : 'PENDING PAYMENT',
                            style: TextStyle(
                              color: isPaid ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Merchant Business Info
                    Text(
                      _invoice.merchantBusinessName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    if (_invoice.merchantWalletTag != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@${_invoice.merchantWalletTag}',
                        style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Grand Total Display
                    Text(
                      CurrencyFormatter.format(_invoice.grandTotal),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? AppColors.accent : AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // QR Code (if pending)
                    if (!isPaid && _invoice.qrCodePayload != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: _invoice.qrCodePayload!,
                          version: QrVersions.auto,
                          size: 160.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Customer can scan QR with BATWA to pay',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),

                    // Invoice Metadata
                    _buildMetaRow('Invoice Number', '#${_invoice.invoiceNumber}'),
                    if (_invoice.customerName != null) _buildMetaRow('Billed To', _invoice.customerName!),
                    if (_invoice.createdAt != null)
                      _buildMetaRow('Date Issued', CurrencyFormatter.formatShortDate(_invoice.createdAt!)),
                    if (_invoice.transactionReference != null)
                      _buildMetaRow('Transaction Ref', _invoice.transactionReference!),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),

                    // Items List
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Itemized Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    ..._invoice.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.itemName}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              CurrencyFormatter.format(item.totalPrice),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 12),

                    // Subtotal & Tax Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(CurrencyFormatter.format(_invoice.subtotal), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax (${_invoice.taxRatePercentage.toStringAsFixed(0)}%)',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(CurrencyFormatter.format(_invoice.taxAmount), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (!isPaid)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _showPayModal,
                    icon: const Icon(Icons.payment_rounded, color: Colors.white),
                    label: const Text('Pay This Invoice Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
