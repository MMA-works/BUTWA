import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_bloc.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_event.dart';
import 'package:batwa_wallet/features/merchant/presentation/bloc/merchant_state.dart';
import 'package:batwa_wallet/features/merchant/presentation/screens/invoice_detail_screen.dart';

class _ItemRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<_ItemRow> _itemRows = [];
  double _taxRate = 0.0;

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _descriptionController.dispose();
    for (var r in _itemRows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      final row = _ItemRow();
      row.qtyController.addListener(() => setState(() {}));
      row.priceController.addListener(() => setState(() {}));
      _itemRows.add(row);
    });
  }

  void _removeItem(int index) {
    if (_itemRows.length > 1) {
      setState(() {
        _itemRows[index].dispose();
        _itemRows.removeAt(index);
      });
    }
  }

  double get _subtotal {
    double sum = 0.0;
    for (var r in _itemRows) {
      final qty = int.tryParse(r.qtyController.text) ?? 0;
      final price = double.tryParse(r.priceController.text) ?? 0.0;
      sum += qty * price;
    }
    return sum;
  }

  double get _taxAmount => _subtotal * (_taxRate / 100.0);
  double get _grandTotal => _subtotal + _taxAmount;

  void _submit() {
    List<Map<String, dynamic>> items = [];
    for (var r in _itemRows) {
      final name = r.nameController.text.trim();
      final qty = int.tryParse(r.qtyController.text) ?? 0;
      final price = double.tryParse(r.priceController.text) ?? 0.0;

      if (name.isEmpty || qty <= 0 || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all invoice item details properly')),
        );
        return;
      }

      items.add({
        'itemName': name,
        'quantity': qty,
        'unitPrice': price,
      });
    }

    context.read<MerchantBloc>().add(
          CreateInvoiceEvent(
            customerIdentifier: _customerController.text.trim().isNotEmpty ? _customerController.text.trim() : null,
            customerName: _customerController.text.trim().isNotEmpty ? _customerController.text.trim() : null,
            description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
            taxRatePercentage: _taxRate,
            items: items,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocListener<MerchantBloc, MerchantState>(
        listener: (context, state) {
          if (state is InvoiceCreatedState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: state.invoice)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Billed To (Customer Details)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customerController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_rounded, color: AppColors.accent, size: 20),
                        hintText: 'Customer Wallet Tag / Email / Name (Optional)',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                    label: const Text('Add Item', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Item Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itemRows.length,
                itemBuilder: (context, index) {
                  final row = _itemRows[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder.withOpacity(0.7)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: row.nameController,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Item Name / Description',
                                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_itemRows.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                onPressed: () => _removeItem(index),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: row.qtyController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'Qty',
                                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: row.priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'Unit Price (\S)',
                                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tax Rate Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tax / VAT Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [0.0, 5.0, 10.0, 15.0, 18.0].map((rate) {
                        final isSelected = _taxRate == rate;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _taxRate = rate),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? AppColors.accent : AppColors.cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  rate == 0 ? '0%' : '${rate.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Breakdown Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(CurrencyFormatter.format(_subtotal), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax (${_taxRate.toStringAsFixed(0)}%)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(CurrencyFormatter.format(_taxAmount), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(
                          CurrencyFormatter.format(_grandTotal),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _grandTotal > 0 ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Generate & Issue Digital Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
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
