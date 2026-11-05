import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import '../bloc/splits_bloc.dart';
import '../bloc/splits_event.dart';

class CreateSplitScreen extends StatefulWidget {
  const CreateSplitScreen({super.key});

  @override
  State<CreateSplitScreen> createState() => _CreateSplitScreenState();
}

class _CreateSplitScreenState extends State<CreateSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _participantController = TextEditingController();

  final List<String> _participants = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final text = _participantController.text.trim();
    if (text.isEmpty) return;

    final cleaned = text.startsWith('@') ? text.substring(1) : text;

    if (_participants.contains(cleaned)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Participant already added!'),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _participants.add(cleaned);
      _participantController.clear();
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  double get _totalAmount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  double get _splitShare {
    final totalPeople = _participants.length + 1; // including creator
    if (_totalAmount <= 0 || totalPeople <= 0) return 0.0;
    return _totalAmount / totalPeople;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_participants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least 1 participant to split with.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<SplitsBloc>().add(
            CreateSplitEvent(
              title: _titleController.text.trim(),
              totalAmount: _totalAmount,
              note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
              participantIdentifiers: _participants,
            ),
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Split a Bill',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Title
                    const Text('BILL TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g. Kolachi Dinner, Netflix Plan, Uber Ride',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),

                    // Total Amount
                    const Text('TOTAL BILL AMOUNT (PKR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter total amount';
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Note
                    const Text('NOTE / DESCRIPTION (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g. Paid via card, please settle by tonight',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Share Breakdown Preview Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface,
                            AppColors.surface.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.calculate_rounded, color: AppColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Equal Share Breakdown',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                              Text(
                                '${_participants.length + 1} People Total',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.cardBorder),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Each Person Pays:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(
                                CurrencyFormatters.formatPkr(_splitShare),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Participants Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ADD FRIENDS (WALLET TAG OR EMAIL)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        Text(
                          '${_participants.length} added',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _participantController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'e.g. ali_123 or user@batwa.com',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary, size: 20),
                            ),
                            onSubmitted: (_) => _addParticipant(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addParticipant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Participant Chips List
                    if (_participants.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
                        ),
                        child: const Center(
                          child: Text(
                            'No friends added yet. Enter wallet tags above to divide the bill.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_participants.length, (index) {
                          final item = _participants[index];
                          return Chip(
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.primary),
                            avatar: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              child: Text(
                                item.isNotEmpty ? item[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            label: Text(
                              '@$item',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                            onDeleted: () => _removeParticipant(index),
                          );
                        }),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Submit CTA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Send Split Requests (${CurrencyFormatters.formatPkr(_splitShare)} / person)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
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
}
