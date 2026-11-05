import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';

class CreateRecurringDialog extends StatefulWidget {
  const CreateRecurringDialog({super.key});

  @override
  State<CreateRecurringDialog> createState() => _CreateRecurringDialogState();
}

class _CreateRecurringDialogState extends State<CreateRecurringDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();

  final _recipientFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _pinFocus = FocusNode();

  String _selectedFrequency = 'MONTHLY';

  final List<Map<String, String>> _frequencies = [
    {'key': 'DAILY', 'label': 'Daily', 'desc': 'Every 24h'},
    {'key': 'WEEKLY', 'label': 'Weekly', 'desc': '7 Days'},
    {'key': 'MONTHLY', 'label': 'Monthly', 'desc': '30 Days'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    _recipientFocus.dispose();
    _amountFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      context.read<RecurringBloc>().add(
            CreateRecurringEvent(
              title: _titleController.text.trim(),
              recipientIdentifier: _recipientController.text.trim(),
              amount: amount,
              frequency: _selectedFrequency,
              pin: _pinController.text.trim(),
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E5D7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.autorenew_rounded, color: AppColors.textPrimary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Create Auto-Debit Rule',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Automate regular transfers to merchants, friends, or utility bills with in-house scheduled debits.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 20),

                  // Title / Purpose
                  const Text('PAYMENT PURPOSE / TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_recipientFocus),
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F4EB),
                      hintText: 'e.g. Apartment Rent, Internet Bill, Gym',
                      hintStyle: const TextStyle(color: Color(0xFF8E9584), fontSize: 14),
                      prefixIcon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Recipient Identifier
                  const Text('RECIPIENT (TAG, PHONE OR EMAIL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _recipientController,
                    focusNode: _recipientFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_amountFocus),
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F4EB),
                      hintText: 'e.g. starcoffee or merchant@batwa.com',
                      hintStyle: const TextStyle(color: Color(0xFF8E9584), fontSize: 14),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter recipient tag or email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  const Text('AMOUNT (PKR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_pinFocus),
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F4EB),
                      hintText: 'e.g. 5000',
                      hintStyle: const TextStyle(color: Color(0xFF8E9584), fontSize: 14),
                      prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter amount';
                      final n = double.tryParse(val.trim());
                      if (n == null || n <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Frequency Selector
                  const Text('PAYMENT FREQUENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: _frequencies.map((f) {
                      final isSelected = _selectedFrequency == f['key'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFrequency = f['key']!),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent : const Color(0xFFF1F4EB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  f['label']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f['desc']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.textPrimary.withOpacity(0.7) : const Color(0xFF8E9584),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Authorize with MPIN
                  const Text('AUTHORIZE WITH 4-DIGIT MPIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pinController,
                    focusNode: _pinFocus,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 8, fontSize: 20, fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F4EB),
                      hintText: '••••',
                      hintStyle: const TextStyle(letterSpacing: 0, color: Color(0xFF8E9584)),
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (val) {
                      if (val == null || val.length != 4) return 'Enter 4-digit MPIN';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button (Matte Black with Neon Lime / Text)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Activate Auto-Debit',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}