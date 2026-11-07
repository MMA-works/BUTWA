import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_event.dart';

class SetBudgetDialog extends StatefulWidget {
  final String currentPeriod;
  final BudgetEntity? existingBudget;
  final String? initialCategory;

  const SetBudgetDialog({
    super.key,
    required this.currentPeriod,
    this.existingBudget,
    this.initialCategory,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late String _selectedCategory;
  late final TextEditingController _amountController;
  double _threshold = 80;
  bool _isSubmitting = false;
  bool _isDeleting = false;

  final List<Map<String, dynamic>> _categories = const [
    {'code': 'FOOD', 'name': 'Food & Dining', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFF59E0B)},
    {'code': 'SHOPPING', 'name': 'Shopping & Retail', 'icon': Icons.shopping_bag_rounded, 'color': Color(0xFFEC4899)},
    {'code': 'ENTERTAINMENT', 'name': 'Entertainment', 'icon': Icons.movie_rounded, 'color': Color(0xFF8B5CF6)},
    {'code': 'BILLS_UTILITIES', 'name': 'Bills & Utilities', 'icon': Icons.receipt_long_rounded, 'color': Color(0xFF3B82F6)},
    {'code': 'TRANSFERS', 'name': 'Transfers', 'icon': Icons.swap_horiz_rounded, 'color': Color(0xFF10B981)},
    {'code': 'HEALTH', 'name': 'Health & Care', 'icon': Icons.favorite_rounded, 'color': Color(0xFFEF4444)},
    {'code': 'EDUCATION', 'name': 'Education', 'icon': Icons.school_rounded, 'color': Color(0xFF06B6D4)},
    {'code': 'TRAVEL', 'name': 'Travel & Trips', 'icon': Icons.flight_takeoff_rounded, 'color': Color(0xFFF97316)},
    {'code': 'INVESTMENT', 'name': 'Investments', 'icon': Icons.trending_up_rounded, 'color': Color(0xFF14B8A6)},
    {'code': 'GENERAL', 'name': 'General Expenses', 'icon': Icons.category_rounded, 'color': Color(0xFF64748B)},
  ];

  final List<double> _quickAmounts = const [2000, 5000, 10000, 25000, 50000];

  @override
  void initState() {
    super.initState();
    // Normalize category if matching legacy names
    String defaultCat = widget.existingBudget?.category ?? widget.initialCategory ?? 'FOOD';
    if (defaultCat == 'FOOD_AND_DINING') defaultCat = 'FOOD';
    if (defaultCat == 'UTILITIES') defaultCat = 'BILLS_UTILITIES';
    if (defaultCat == 'TRANSPORT') defaultCat = 'TRAVEL';

    _selectedCategory = defaultCat;
    _amountController = TextEditingController(
      text: widget.existingBudget != null
          ? widget.existingBudget!.monthlyLimit.toStringAsFixed(0)
          : '',
    );
    _threshold = widget.existingBudget != null
        ? widget.existingBudget!.alertThresholdPercentage.toDouble()
        : 80;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly budget limit (minimum Rs 1)'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final bloc = context.read<AnalyticsBloc>();
      await bloc.analyticsRepository.setBudget(
        category: _selectedCategory,
        monthlyLimit: amount,
        monthPeriod: widget.currentPeriod,
        alertThresholdPercentage: _threshold.toInt(),
      );

      // Refresh Analytics state
      bloc.add(LoadAnalyticsSummaryEvent(period: widget.currentPeriod));

      if (mounted) {
        Navigator.pop(context, true);
        final catName = _categories.firstWhere(
          (c) => c['code'] == _selectedCategory,
          orElse: () => {'name': _selectedCategory},
        )['name'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFF3D602), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Budget of Rs ${amount.toStringAsFixed(0)} set for $catName!',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF042B1D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set budget: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteBudget() async {
    if (widget.existingBudget == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Budget Target?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to remove this category budget limit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    HapticFeedback.mediumImpact();

    try {
      final bloc = context.read<AnalyticsBloc>();
      await bloc.analyticsRepository.deleteBudget(widget.existingBudget!.id);
      bloc.add(LoadAnalyticsSummaryEvent(period: widget.currentPeriod));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget target removed successfully'),
            backgroundColor: Color(0xFF042B1D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove budget: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141722) : Colors.white;
    final inputBg = isDark ? const Color(0xFF1C2030) : const Color(0xFFF8F9FA);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF1B1D28);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF042B1D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFF3D602),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingBudget != null ? 'Edit Budget Target' : 'Set Monthly Budget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Period: ${widget.currentPeriod}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textColor.withValues(alpha: 0.6)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set monthly spending limits per category to manage your money with intelligent alerts.',
              style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // Category Selector
            Text(
              'Expense Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E2333) : Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF042B1D)),
                  items: _categories.map((c) {
                    final code = c['code'] as String;
                    final name = c['name'] as String;
                    final icon = c['icon'] as IconData;
                    final color = c['color'] as Color;
                    return DropdownMenuItem<String>(
                      value: code,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, size: 18, color: color),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            name,
                            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Monthly Limit Amount
            Text(
              'Monthly Spending Limit (Rs)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: textColor),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    'Rs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF042B1D),
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: 'e.g. 5,000',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF042B1D), width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Quick Preset Amount Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _quickAmounts.map((q) {
                  final isSelected = _amountController.text.trim() == q.toStringAsFixed(0);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _amountController.text = q.toStringAsFixed(0);
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF042B1D)
                              : (isDark ? const Color(0xFF1E2333) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFF3D602) : borderColor,
                          ),
                        ),
                        child: Text(
                          'Rs ${q >= 1000 ? "${(q / 1000).toStringAsFixed(0)}k" : q.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFFF3D602)
                                : (isDark ? Colors.white70 : const Color(0xFF334155)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Threshold Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alert Warning Threshold',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_threshold.toInt()}% used',
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF042B1D),
                inactiveTrackColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                thumbColor: const Color(0xFFF3D602),
                overlayColor: const Color(0xFFF3D602).withValues(alpha: 0.25),
                trackHeight: 5,
              ),
              child: Slider(
                value: _threshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${_threshold.toInt()}%',
                onChanged: (val) => setState(() => _threshold = val),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _isDeleting) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF042B1D),
                  foregroundColor: const Color(0xFFF3D602),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFF3D602),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFFF3D602)),
                          const SizedBox(width: 8),
                          Text(
                            widget.existingBudget != null ? 'Update Budget Target' : 'Save Budget Target',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
              ),
            ),

            // Delete option if editing existing budget
            if (widget.existingBudget != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: (_isSubmitting || _isDeleting) ? null : _deleteBudget,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isDeleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red.shade700),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Remove This Budget Target', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          ],
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
