import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import '../bloc/vaults_bloc.dart';
import '../bloc/vaults_event.dart';

class CreateVaultScreen extends StatefulWidget {
  const CreateVaultScreen({super.key});

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedIcon = 'savings';
  String _selectedColor = '#10B981';
  DateTime? _targetDate;
  bool _isLocked = false;

  final List<Map<String, dynamic>> _presetIcons = [
    {'icon': Icons.savings_rounded, 'name': 'savings', 'label': 'Piggy Pot'},
    {'icon': Icons.flight_takeoff_rounded, 'name': 'travel', 'label': 'Travel'},
    {'icon': Icons.devices_other_rounded, 'name': 'gadgets', 'label': 'Gadgets'},
    {'icon': Icons.directions_car_rounded, 'name': 'car', 'label': 'Vehicle'},
    {'icon': Icons.home_rounded, 'name': 'home', 'label': 'Dream Home'},
    {'icon': Icons.favorite_rounded, 'name': 'emergency', 'label': 'Emergency'},
    {'icon': Icons.mosque_rounded, 'name': 'hajj', 'label': 'Pilgrimage'},
    {'icon': Icons.celebration_rounded, 'name': 'wedding', 'label': 'Wedding'},
  ];

  final List<String> _presetColors = [
    '#10B981', // Emerald
    '#6366F1', // Indigo
    '#EC4899', // Pink
    '#F59E0B', // Amber
    '#3B82F6', // Blue
    '#8B5CF6', // Purple
    '#14B8A6', // Teal
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      context.read<VaultsBloc>().add(
            CreateVaultEvent(
              name: _nameController.text.trim(),
              targetAmount: amount,
              icon: _selectedIcon,
              colorHex: _selectedColor,
              targetDate: _targetDate,
              isLocked: _isLocked,
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
          'Create Savings Pot',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Segregate your wallet balance into dedicated goal vaults with target countdowns.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Goal Name
                      const Text('POT NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. iPhone 16 Pro, New Laptop, Umrah Trip',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.label_outline_rounded, color: AppColors.textSecondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a goal name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Target Amount
                      const Text('TARGET AMOUNT (PKR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'e.g. 50000',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.textSecondary),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a target amount';
                          final numVal = double.tryParse(val.trim());
                          if (numVal == null || numVal <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Choose Category Icon
                      const Text('ICON CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _presetIcons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final item = _presetIcons[idx];
                            final isSelected = _selectedIcon == item['name'];
                            return InkWell(
                              onTap: () => setState(() => _selectedIcon = item['name']),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item['icon'] as IconData,
                                      size: 18,
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Theme Color Selection
                      const Text('POT COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Row(
                        children: _presetColors.map((hex) {
                          final color = _parseHex(hex);
                          final isSelected = _selectedColor == hex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = hex),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Target Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Deadline (Optional)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                _targetDate == null
                                    ? 'No deadline set'
                                    : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: _pickTargetDate,
                            icon: const Icon(Icons.calendar_month_rounded, size: 16),
                            label: Text(_targetDate == null ? 'Set Date' : 'Change'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Impulse Lock Switch
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: AppColors.warning, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Strict Lock Mode',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  ),
                                  Text(
                                    'Prevents impulsive spending. Unlocking requires your secure wallet PIN.',
                                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isLocked,
                              onChanged: (val) => setState(() => _isLocked = val),
                              activeColor: AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
                    child: const Text(
                      'Create Savings Pot',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
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
