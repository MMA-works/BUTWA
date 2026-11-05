import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_bloc.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_event.dart';

class RegisterMerchantSheet extends StatefulWidget {
  final String? initialBusinessName;
  final String? initialCategory;

  const RegisterMerchantSheet({
    super.key,
    this.initialBusinessName,
    this.initialCategory,
  });

  @override
  State<RegisterMerchantSheet> createState() => _RegisterMerchantSheetState();
}

class _RegisterMerchantSheetState extends State<RegisterMerchantSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _taxController;
  late final TextEditingController _addressController;
  String _category = 'RESTAURANT';

  final List<Map<String, String>> _categories = [
    {'code': 'RESTAURANT', 'name': 'Restaurant & Cafe'},
    {'code': 'RETAIL', 'name': 'Retail & Supermarket'},
    {'code': 'GROCERY', 'name': 'Grocery & Mart'},
    {'code': 'SERVICES', 'name': 'Professional Services'},
    {'code': 'TECH', 'name': 'Tech & Digital Goods'},
    {'code': 'HEALTHCARE', 'name': 'Pharmacy & Health'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialBusinessName ?? '');
    _taxController = TextEditingController();
    _addressController = TextEditingController();
    if (widget.initialCategory != null) {
      _category = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your business or store name')),
      );
      return;
    }

    context.read<MerchantBloc>().add(
          RegisterMerchantProfileEvent(
            businessName: _nameController.text.trim(),
            businessCategory: _category,
            taxId: _taxController.text.trim().isNotEmpty ? _taxController.text.trim() : null,
            storeAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Merchant Store Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Accept instant QR payments, issue professional invoices, and run POS checkouts.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.85)),
            ),
            const SizedBox(height: 20),

            // Business Name
            const Text(
              'Store / Business Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.storefront_rounded, color: AppColors.accent),
                hintText: 'e.g. Star Coffee & Bites',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            const Text(
              'Business Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accent),
                  items: _categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['code']!,
                      child: Text(
                        c['name']!,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tax ID
            const Text(
              'Tax ID / NTN Number (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taxController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.receipt_rounded, color: AppColors.textSecondary),
                hintText: 'e.g. NTN-9849201',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            const Text(
              'Store Address / City (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.textSecondary),
                hintText: 'e.g. F-7 Blue Area, Islamabad',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Save & Activate Merchant Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
