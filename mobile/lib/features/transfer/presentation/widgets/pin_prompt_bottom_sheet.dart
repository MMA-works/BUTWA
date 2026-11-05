import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';

class PinPromptBottomSheet extends StatefulWidget {
  final String recipientName;
  final String recipientTag;
  final double amount;
  final double fee;
  final bool isLoading;
  final Function(String pin) onPinConfirmed;

  const PinPromptBottomSheet({
    super.key,
    required this.recipientName,
    required this.recipientTag,
    required this.amount,
    required this.fee,
    required this.isLoading,
    required this.onPinConfirmed,
  });

  @override
  State<PinPromptBottomSheet> createState() => _PinPromptBottomSheetState();
}

class _PinPromptBottomSheetState extends State<PinPromptBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 4-6 digit PIN'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    widget.onPinConfirmed(_pinController.text);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.amount + widget.fee;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.accent, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Authorize Transfer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sending to:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text(
                        '${widget.recipientName} (@${widget.recipientTag})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transfer Amount:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text(
                        CurrencyFormatter.format(widget.amount),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Fee (0.5%):', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text(
                        CurrencyFormatter.format(widget.fee),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.divider, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Debit:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        CurrencyFormatter.format(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: _obscure,
              maxLength: 6,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SpinKitThreeBounce(color: Colors.black, size: 24)
                  : const Text('Confirm & Authorize'),
            ),
          ],
        ),
      ),
    );
  }
}
