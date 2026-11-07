import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/bills/data/bills_remote_datasource.dart';
import 'package:batwa_wallet/features/bills/data/bills_repository_impl.dart';
import 'package:batwa_wallet/features/bills/domain/entities/bill_company_entity.dart';
import 'package:batwa_wallet/features/bills/domain/entities/bill_inquiry_entity.dart';
import 'package:batwa_wallet/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:batwa_wallet/features/bills/presentation/bloc/bills_event.dart';
import 'package:batwa_wallet/features/bills/presentation/bloc/bills_state.dart';
import 'package:batwa_wallet/features/bills/presentation/screens/bill_receipt_screen.dart';

class BillInquiryScreen extends StatelessWidget {
  final BillCompanyEntity company;

  const BillInquiryScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillsBloc(
        repository: BillsRepositoryImpl(
          remoteDataSource: BillsRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      ),
      child: _BillInquiryView(company: company),
    );
  }
}

class _BillInquiryView extends StatefulWidget {
  final BillCompanyEntity company;

  const _BillInquiryView({required this.company});

  @override
  State<_BillInquiryView> createState() => _BillInquiryViewState();
}

class _BillInquiryViewState extends State<_BillInquiryView> {
  final TextEditingController _consumerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill helper sample numbers for easy demo testing
    if (widget.company.companyCode.toUpperCase() == 'KE') {
      _consumerController.text = '1234567890123';
    } else if (widget.company.companyCode.toUpperCase() == 'SNGPL') {
      _consumerController.text = '98765432101';
    } else if (widget.company.companyCode.toUpperCase() == 'NAYATEL') {
      _consumerController.text = '5551234567';
    }
  }

  @override
  void dispose() {
    _consumerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.company.companyName),
        centerTitle: true,
      ),
      body: BlocConsumer<BillsBloc, BillsState>(
        listener: (context, state) {
          if (state is BillsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BillPaymentSuccessState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BillReceiptScreen(payment: state.payment),
              ),
            );
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isLoading = state is BillsLoadingState || state is BillPaymentProcessingState;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1D28) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/banks/${widget.company.companyCode.toLowerCase()}.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2205) : const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getCompanyIcon(widget.company.category),
                              color: const Color(0xFFD97706),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.company.companyName,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.darkNavy,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${widget.company.category} • Length: ${widget.company.consumerNoLength} digits',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Consumer Number / Account ID',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _consumerController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontFamily: 'monospace',
                          fontSize: 16,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 1234567890123',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.cardBorder),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: AppColors.primaryYellow, width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search_rounded, color: Color(0xFFD97706)),
                            onPressed: () => _inquireBill(context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter consumer number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: const Color(0xFF042B1D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : () => _inquireBill(context),
                          child: isLoading && state is BillsLoadingState
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF042B1D)),
                                )
                              : const Text(
                                  'Fetch Bill Details',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Bill Inquiry Details Card
                if (state is BillInquiryLoadedState) ...[
                  _buildInquiryCard(context, state.inquiry, isLoading),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _inquireBill(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<BillsBloc>().add(
            InquireBillEvent(
              companyCode: widget.company.companyCode,
              consumerNumber: _consumerController.text.trim(),
            ),
          );
    }
  }

  Widget _buildInquiryCard(BuildContext context, BillInquiryEntity inquiry, bool isProcessing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D28) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inquiry.isPaid
              ? (isDark ? Colors.white10 : AppColors.cardBorder)
              : inquiry.isOverdue
                  ? Colors.red.shade400
                  : AppColors.primaryYellow,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BILL DETAILS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: inquiry.isPaid
                      ? Colors.green.withValues(alpha: 0.15)
                      : inquiry.isOverdue
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inquiry.isPaid
                      ? 'PAID'
                      : inquiry.isOverdue
                          ? 'OVERDUE'
                          : 'UNPAID',
                  style: TextStyle(
                    color: inquiry.isPaid
                        ? Colors.green
                        : inquiry.isOverdue
                            ? Colors.red
                            : Colors.amber.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInquiryRow('Consumer Name', inquiry.consumerName, isDark),
          const SizedBox(height: 10),
          _buildInquiryRow('Billing Month', inquiry.billingMonth, isDark),
          const SizedBox(height: 10),
          _buildInquiryRow('Due Date', inquiry.dueDate.toString().split(' ')[0], isDark),
          Divider(color: isDark ? Colors.white10 : AppColors.cardBorder, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Payable Amount',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              Text(
                'Rs. ${inquiry.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark ? AppColors.primaryYellow : const Color(0xFF042B1D),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (inquiry.isPaid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2433) : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'This utility bill has already been settled.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: const Color(0xFF042B1D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 20),
                label: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF042B1D)),
                      )
                    : const Text(
                        'Pay Bill with BATWA',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                onPressed: isProcessing ? null : () => _showPinBottomSheet(context, inquiry.billId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInquiryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showPinBottomSheet(BuildContext parentContext, String billId) {
    final pinController = TextEditingController();
    final isDark = Theme.of(parentContext).brightness == Brightness.dark;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141722) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Authorize Bill Payment',
                style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your 4-digit Transaction MPIN to settle this bill instantly.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.darkNavy,
                  fontSize: 24,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2433) : AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: const Color(0xFF042B1D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final pin = pinController.text.trim();
                    if (pin.length == 4) {
                      Navigator.pop(modalContext);
                      parentContext.read<BillsBloc>().add(
                            PayBillEvent(billId: billId, pin: pin),
                          );
                    }
                  },
                  child: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCompanyIcon(String category) {
    switch (category.toUpperCase()) {
      case 'ELECTRICITY':
        return Icons.bolt_rounded;
      case 'GAS':
        return Icons.local_fire_department_rounded;
      case 'INTERNET':
        return Icons.wifi_rounded;
      case 'WATER':
        return Icons.water_drop_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
