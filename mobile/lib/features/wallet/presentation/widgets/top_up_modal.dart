import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';

class TopUpModal extends StatefulWidget {
  const TopUpModal({super.key});

  @override
  State<TopUpModal> createState() => _TopUpModalState();
}

class _TopUpModalState extends State<TopUpModal> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'DEBIT_CARD';
  final List<double> _quickAmounts = [20, 50, 100, 250, 500];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onTopUp() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount to top-up'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<WalletBloc>().add(
          TopUpSubmittedEvent(
            amount: amount,
            paymentMethod: _selectedMethod,
            description: 'Seed top-up',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is TopUpSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet top-up successful!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TopUpInProgress;

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
                Text(
                  'Top-Up Balance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Simulate adding funds from your linked bank or card',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$ USD)',
                    prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: _quickAmounts.map((amt) {
                    return ActionChip(
                      label: Text('+\$${amt.toInt()}'),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.divider),
                      labelStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      onPressed: () {
                        setState(() {
                          _amountController.text = amt.toStringAsFixed(2);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Funding Method',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMethod,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      items: const [
                        DropdownMenuItem(
                          value: 'DEBIT_CARD',
                          child: Text('Simulated Visa/Mastercard (•••• 4242)'),
                        ),
                        DropdownMenuItem(
                          value: 'BANK_ACCOUNT',
                          child: Text('Simulated Direct Bank ACH'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMethod = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: isLoading ? null : _onTopUp,
                  child: isLoading
                      ? const SpinKitThreeBounce(color: Colors.black, size: 24)
                      : const Text('Confirm Top-Up'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
