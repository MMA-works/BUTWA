import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../../domain/entities/vault_entity.dart';
import '../bloc/vaults_bloc.dart';
import '../bloc/vaults_event.dart';

class VaultActionDialog extends StatefulWidget {
  final VaultEntity vault;
  final bool isDeposit;

  const VaultActionDialog({
    super.key,
    required this.vault,
    required this.isDeposit,
  });

  @override
  State<VaultActionDialog> createState() => _VaultActionDialogState();
}

class _VaultActionDialogState extends State<VaultActionDialog> {
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (widget.isDeposit) {
        context.read<VaultsBloc>().add(
              DepositToVaultEvent(
                vaultId: widget.vault.id,
                amount: amount,
              ),
            );
      } else {
        context.read<VaultsBloc>().add(
              WithdrawFromVaultEvent(
                vaultId: widget.vault.id,
                amount: amount,
                pin: widget.vault.isLocked ? _pinController.text.trim() : null,
              ),
            );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isDeposit ? 'Add Funds to Pot' : 'Withdraw from Pot';
    final subtitle = widget.isDeposit
        ? 'Move money from your main wallet to "${widget.vault.name}".'
        : 'Move money from "${widget.vault.name}" back to your main wallet.';

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isDeposit
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isDeposit ? Icons.add_circle_rounded : Icons.arrow_downward_rounded,
                      color: widget.isDeposit ? AppColors.primary : AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.vault.name,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),

              // Current Pot Balance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pot Balance:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      CurrencyFormatters.formatPkr(widget.vault.currentAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              const Text('AMOUNT (PKR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'Enter a valid amount';
                  if (!widget.isDeposit && numVal > widget.vault.currentAmount) {
                    return 'Cannot withdraw more than pot balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quick Amount Presets
              Row(
                children: [500, 1000, 5000].map((preset) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () {
                          _amountController.text = preset.toString();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('+Rs $preset', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // If withdrawing from a locked pot, require PIN
              if (!widget.isDeposit && widget.vault.isLocked) ...[
                const Text('WALLET PIN (LOCKED POT)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white, letterSpacing: 6),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 4),
                    filled: true,
                    fillColor: AppColors.background,
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.warning),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 4) return 'Enter your 4-6 digit PIN';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDeposit ? AppColors.primary : AppColors.warning,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.isDeposit ? 'Deposit' : 'Withdraw',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
