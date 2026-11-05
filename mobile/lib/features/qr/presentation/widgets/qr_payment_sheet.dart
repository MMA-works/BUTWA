import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import '../../domain/entities/qr_preview_entity.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';

class QrPaymentSheet extends StatefulWidget {
  final QrPreviewEntity preview;

  const QrPaymentSheet({super.key, required this.preview});

  @override
  State<QrPaymentSheet> createState() => _QrPaymentSheetState();
}

class _QrPaymentSheetState extends State<QrPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  final _pinCtrl = TextEditingController();
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.preview.amount != null ? widget.preview.amount!.toStringAsFixed(2) : '',
    );
    _noteCtrl = TextEditingController(text: widget.preview.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
      context.read<QrBloc>().add(
            PayQrEvent(
              recipientWalletId: widget.preview.recipientWalletId ?? '',
              amount: amount,
              note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
              referenceCode: widget.preview.referenceCode,
              pin: _pinCtrl.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocConsumer<QrBloc, QrState>(
        listener: (context, state) {
          if (state is QrPaymentSuccessState) {
            Navigator.of(context).pop();
            _showSuccessDialog(context, state);
          } else if (state is QrErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isProcessing = state is QrPaymentProcessingState;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Instant QR Payment',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Recipient Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.preview.recipientName ?? 'Recipient',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                widget.preview.recipientEmail ?? '',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  const Text('PAYMENT AMOUNT (PKR)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountCtrl,
                    readOnly: !widget.preview.isAmountEditable,
                    focusNode: !widget.preview.isAmountEditable ? FocusNode(canRequestFocus: false) : null,
                    enableInteractiveSelection: widget.preview.isAmountEditable,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      color: widget.preview.isAmountEditable ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      prefixText: 'Rs ',
                      prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      suffixIcon: !widget.preview.isAmountEditable
                          ? const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18)
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter amount';
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) return 'Invalid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Note Field
                  const Text('NOTE / REFERENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      hintText: 'Optional transfer note',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // MPIN Field
                  const Text('ENTER 4-DIGIT MPIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _pinCtrl,
                    autofocus: true,
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    onChanged: (val) {
                      if (val.trim().length == 4) {
                        FocusScope.of(context).unfocus();
                        _submit();
                      }
                    },
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 8, fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length != 4) return 'Enter valid 4-digit MPIN';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isProcessing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Authorize & Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, QrPaymentSuccessState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Sent!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Rs ${state.amount.toStringAsFixed(2)} has been successfully transferred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
