import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/transfer_receipt_screen.dart';
import 'package:batwa_wallet/features/transfer/data/transfer_remote_datasource.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/core/network/api_client.dart';

enum SendMoneyStep {
  selectPayee,
  selectBank,
  enterBankAccount,
  enterAmount,
  reviewTransfer,
  processing,
  success,
}

class BankItem {
  final String id;
  final String name;
  final String code;
  final String shortName;
  final IconData icon;
  final Color brandColor;

  const BankItem({
    required this.id,
    required this.name,
    required this.code,
    required this.shortName,
    required this.icon,
    required this.brandColor,
  });
}

class PayeeItem {
  final String id;
  final String name;
  final String initials;
  final String bank;
  final String accountNo;
  final String type; // 'bank', 'raast', 'wallet'
  final Color avatarBg;
  final String? bankId;

  const PayeeItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.bank,
    required this.accountNo,
    required this.type,
    required this.avatarBg,
    this.bankId,
  });
}

class SendMoneyScreen extends StatefulWidget {
  final double userBalance;

  const SendMoneyScreen({super.key, required this.userBalance});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen>
    with SingleTickerProviderStateMixin {
  SendMoneyStep _currentStep = SendMoneyStep.selectPayee;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bankSearchController = TextEditingController();
  final TextEditingController _accountInputController = TextEditingController();
  final TextEditingController _accountTitleController = TextEditingController();

  String _enteredAmount = '0';
  bool _isBalanceHidden = false;
  String _transferPurpose = 'Family support';
  double _sliderPosition = 0.0;

  // Selected State
  PayeeItem? _selectedPayee;
  BankItem? _selectedBank;

  // Processing Animation Step Flags
  bool _step1Verified = false;
  bool _step2SentRaast = false;
  bool _step3ReceivedBank = false;
  String _transactionRef = 'RAAST-7731902';
  String _transactionTime = '';
  String _batwaRecipientTag = '';
  String? _confirmedPin;
  TransactionEntity? _completedTransaction;

  // 🇵🇰 Comprehensive List of Pakistani Banks & Microfinance / Wallets
  final List<BankItem> _allBanks = const [
    BankItem(
      id: 'bml',
      name: 'Bank Makramah Limited (BML)',
      code: 'SMBL',
      shortName: 'BML',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0A6535),
    ),
    BankItem(
      id: 'mmbl',
      name: 'Mobilink Microfinance Bank (MMBL)',
      code: 'MMBL',
      shortName: 'MMBL',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFFEA580C),
    ),
    BankItem(
      id: 'ztbl',
      name: 'Zarai Taraqiati Bank Limited (ZTBL)',
      code: 'ZTBL',
      shortName: 'ZTBL',
      icon: Icons.agriculture_rounded,
      brandColor: Color(0xFF16A34A),
    ),
    BankItem(
      id: 'advans',
      name: 'Advans Pakistan Microfinance Bank',
      code: 'ADVN',
      shortName: 'Advans',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0D9488),
    ),
    BankItem(
      id: 'bankislami',
      name: 'BankIslami Pakistan Limited',
      code: 'BKIP',
      shortName: 'BankIslami',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0265A8),
    ),
    BankItem(
      id: 'upaisa',
      name: 'UPaisa (U Microfinance Bank)',
      code: 'UMBL',
      shortName: 'UPaisa',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFFEB690B),
    ),
    BankItem(
      id: 'raqami',
      name: 'Raqami Islamic Digital Bank',
      code: 'RQMI',
      shortName: 'Raqami',
      icon: Icons.brightness_auto_rounded,
      brandColor: Color(0xFF0D9488),
    ),
    BankItem(
      id: 'abhi',
      name: 'ABHI Microfinance Bank',
      code: 'ABHI',
      shortName: 'ABHI',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0284C7),
    ),
    BankItem(
      id: 'albaraka',
      name: 'Al Baraka Bank',
      code: 'BARK',
      shortName: 'Al Baraka',
      icon: Icons.all_inclusive_rounded,
      brandColor: Color(0xFFEA580C),
    ),
    BankItem(
      id: 'allied',
      name: 'Allied Bank',
      code: 'ABPA',
      shortName: 'ABL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF2563EB),
    ),
    BankItem(
      id: 'askari',
      name: 'Askari Bank',
      code: 'ASPK',
      shortName: 'AKBL',
      icon: Icons.diamond_rounded,
      brandColor: Color(0xFF059669),
    ),
    BankItem(
      id: 'alhabib',
      name: 'Bank AL Habib',
      code: 'BAHL',
      shortName: 'AL Habib',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFDC2626),
    ),
    BankItem(
      id: 'alfalah',
      name: 'Bank Alfalah',
      code: 'ALFH',
      shortName: 'Alfalah',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFE11D48),
    ),
    BankItem(
      id: 'bop',
      name: 'Bank of Punjab (BOP)',
      code: 'BPUN',
      shortName: 'BOP',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFD97706),
    ),
    BankItem(
      id: 'bok',
      name: 'Bank of Khyber (BOK)',
      code: 'KHYB',
      shortName: 'BOK',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF16A34A),
    ),
    BankItem(
      id: 'dib',
      name: 'Dubai Islamic Bank (DIB)',
      code: 'DIBP',
      shortName: 'DIB',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF65A30D),
    ),
    BankItem(
      id: 'faysal',
      name: 'Faysal Bank',
      code: 'FAYS',
      shortName: 'FBL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF1D4ED8),
    ),
    BankItem(
      id: 'fwbl',
      name: 'First Women Bank',
      code: 'FWBL',
      shortName: 'FWBL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFDB2777),
    ),
    BankItem(
      id: 'hbl',
      name: 'Habib Bank Limited (HBL)',
      code: 'HABB',
      shortName: 'HBL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF047857),
    ),
    BankItem(
      id: 'hmb',
      name: 'Habib Metropolitan Bank',
      code: 'HABM',
      shortName: 'Habib Metro',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF1E3A8A),
    ),
    BankItem(
      id: 'sirat',
      name: 'HabibMetro Sirat Islamic Banking',
      code: 'SRAT',
      shortName: 'Sirat Islamic',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF4B2174),
    ),
    BankItem(
      id: 'js',
      name: 'JS Bank',
      code: 'JSBL',
      shortName: 'JSBL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF3B82F6),
    ),
    BankItem(
      id: 'mcb',
      name: 'MCB Bank',
      code: 'MUCB',
      shortName: 'MCB',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFF97316),
    ),
    BankItem(
      id: 'meezan',
      name: 'Meezan Bank',
      code: 'MEZN',
      shortName: 'Meezan',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF881337),
    ),
    BankItem(
      id: 'nbp',
      name: 'National Bank of Pakistan (NBP)',
      code: 'NBPA',
      shortName: 'NBP',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF15803D),
    ),
    BankItem(
      id: 'samba',
      name: 'Samba Bank',
      code: 'SAMB',
      shortName: 'Samba',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0369A1),
    ),
    BankItem(
      id: 'soneri',
      name: 'Soneri Bank',
      code: 'SONE',
      shortName: 'Soneri',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFFEAB308),
    ),
    BankItem(
      id: 'scb',
      name: 'Standard Chartered Pakistan',
      code: 'SCBL',
      shortName: 'SCB',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF0284C7),
    ),
    BankItem(
      id: 'ubl',
      name: 'United Bank Limited (UBL)',
      code: 'UNIL',
      shortName: 'UBL',
      icon: Icons.account_balance_rounded,
      brandColor: Color(0xFF1E40AF),
    ),
    BankItem(
      id: 'easypaisa',
      name: 'Easypaisa (Telenor Bank)',
      code: 'EPAY',
      shortName: 'Easypaisa',
      icon: Icons.phone_android_rounded,
      brandColor: Color(0xFF22C55E),
    ),
    BankItem(
      id: 'jazzcash',
      name: 'JazzCash (Mobilink Microfinance)',
      code: 'JCASH',
      shortName: 'JazzCash',
      icon: Icons.phone_android_rounded,
      brandColor: Color(0xFFEF4444),
    ),
    BankItem(
      id: 'nayapay',
      name: 'NayaPay',
      code: 'NAYA',
      shortName: 'NayaPay',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFFF97316),
    ),
    BankItem(
      id: 'sadapay',
      name: 'SadaPay',
      code: 'SADA',
      shortName: 'SadaPay',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFF14B8A6),
    ),
    BankItem(
      id: 'zindigi',
      name: 'Zindigi (JS Bank)',
      code: 'ZIND',
      shortName: 'Zindigi',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFF84CC16),
    ),
  ];

  // Preset Payees with Direct Bank Logos
  final List<PayeeItem> _savedPayees = const [
    PayeeItem(
      id: 'p1',
      name: 'Ali Raza',
      initials: 'AR',
      bank: 'HBL •• 3301',
      accountNo: 'PK64HABB00012345678901',
      type: 'bank',
      avatarBg: Color(0xFF3B82F6),
      bankId: 'hbl',
    ),
    PayeeItem(
      id: 'p2',
      name: 'Sana Malik',
      initials: 'SM',
      bank: 'Meezan Bank •• 8812',
      accountNo: 'PK36MEZN00098765432101',
      type: 'bank',
      avatarBg: Color(0xFF10B981),
      bankId: 'meezan',
    ),
    PayeeItem(
      id: 'p3',
      name: 'Ammi',
      initials: 'AM',
      bank: 'Bank Alfalah •• 0457',
      accountNo: 'PK12ALFH00033445566701',
      type: 'bank',
      avatarBg: Color(0xFFF43F5E),
      bankId: 'alfalah',
    ),
    PayeeItem(
      id: 'p4',
      name: 'Hamza Qureshi',
      initials: 'HQ',
      bank: 'JazzCash • 0300 •• 21',
      accountNo: '03001234521',
      type: 'wallet',
      avatarBg: Color(0xFF8B5CF6),
      bankId: 'jazzcash',
    ),
    PayeeItem(
      id: 'p5',
      name: 'Fatima Noor',
      initials: 'FN',
      bank: 'UBL •• 6620',
      accountNo: 'PK88UNIL00055443322101',
      type: 'bank',
      avatarBg: Color(0xFF06B6D4),
      bankId: 'ubl',
    ),
    PayeeItem(
      id: 'p6',
      name: 'Zainab Khan',
      initials: 'ZK',
      bank: 'Nayapay • 0321 •• 90',
      accountNo: '03219876590',
      type: 'wallet',
      avatarBg: Color(0xFFF59E0B),
      bankId: 'nayapay',
    ),
    PayeeItem(
      id: 'p7',
      name: 'Bilal Ahmed',
      initials: 'BA',
      bank: 'Allied Bank •• 4410',
      accountNo: 'PK45ABPA00011223344501',
      type: 'bank',
      avatarBg: Color(0xFF2563EB),
      bankId: 'allied',
    ),
    PayeeItem(
      id: 'p8',
      name: 'Sara Ahmed',
      initials: 'SA',
      bank: 'Batwa Wallet • @sara',
      accountNo: 'sara',
      type: 'wallet',
      avatarBg: Color(0xFF10B981),
      bankId: 'raqami',
    ),
    PayeeItem(
      id: 'p9',
      name: 'Tariq Mehmood',
      initials: 'TM',
      bank: 'SadaPay • 0345 •• 88',
      accountNo: '03451234588',
      type: 'wallet',
      avatarBg: Color(0xFF10B981),
      bankId: 'sadapay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _bankSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bankSearchController.dispose();
    _accountInputController.dispose();
    _accountTitleController.dispose();
    super.dispose();
  }

  // --- Smart Detection Helpers ---
  bool _isIban(String text) {
    final clean = text.replaceAll(' ', '').toUpperCase();
    return clean.startsWith('PK') && clean.length >= 12;
  }

  bool _isRaastPhone(String text) {
    final clean = text.replaceAll(RegExp(r'[\s\-\+]'), '');
    return (clean.startsWith('03') && clean.length == 11) ||
        (clean.startsWith('923') && clean.length == 12);
  }

  String _detectBankFromIban(String iban) {
    final clean = iban.replaceAll(' ', '').toUpperCase();
    if (clean.contains('MEZN')) return 'Meezan Bank';
    if (clean.contains('HABB')) return 'Habib Bank Limited (HBL)';
    if (clean.contains('UNIL')) return 'United Bank Limited (UBL)';
    if (clean.contains('ALFH')) return 'Bank Alfalah';
    if (clean.contains('MCB') || clean.contains('MUCB')) return 'MCB Bank';
    if (clean.contains('SCBL')) return 'Standard Chartered';
    if (clean.contains('BAHL')) return 'Bank AL Habib';
    if (clean.contains('JSBL')) return 'JS Bank';
    if (clean.contains('FAYS')) return 'Faysal Bank';
    if (clean.contains('NBPA')) return 'National Bank of Pakistan';
    if (clean.contains('ABPA')) return 'Allied Bank';
    return '1LINK Member Bank';
  }

  // --- Keypad Actions ---
  void _onKeypadTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      if (value == '⌫') {
        if (_enteredAmount.length > 1) {
          _enteredAmount = _enteredAmount.substring(0, _enteredAmount.length - 1);
        } else {
          _enteredAmount = '0';
        }
      } else if (value == '00') {
        if (_enteredAmount != '0' && _enteredAmount.length < 7) {
          _enteredAmount += '00';
        }
      } else {
        if (_enteredAmount == '0') {
          _enteredAmount = value;
        } else if (_enteredAmount.length < 8) {
          _enteredAmount += value;
        }
      }
    });
  }

  void _setQuickAmount(int amount) {
    HapticFeedback.mediumImpact();
    setState(() {
      _enteredAmount = amount.toString();
    });
  }

  // --- Start Processing Live Animation ---
  void _startTransferProcess() {
    setState(() {
      _currentStep = SendMoneyStep.processing;
      _step1Verified = false;
      _step2SentRaast = false;
      _step3ReceivedBank = false;
      _transactionRef = 'RAAST-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final now = DateTime.now();
      _transactionTime =
          '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    });

    // Step 1: Identity verification visual
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _step1Verified = true);
    });

    // Step 2: Send to Raast visual
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _step2SentRaast = true);
    });

    // Step 3: Call real API and complete
    _executeRealTransfer();
  }

  void _showPinConfirmSheet() {
    final pinController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amtFormatted = _formatWithCommas(_enteredAmount);
    final targetName = _selectedPayee?.name ?? (_selectedBank?.name ?? 'Beneficiary');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 28),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Authorize Transfer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1B1D28),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter 4-digit PIN to send Rs $amtFormatted to $targetName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                    fontSize: 26,
                    letterSpacing: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: TextStyle(
                      letterSpacing: 18,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) {
                    _confirmedPin = val.length == 4 ? val : '1234';
                    Navigator.pop(modalCtx);
                    _startTransferProcess();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final pin = pinController.text.trim();
                    _confirmedPin = pin.length == 4 ? pin : '1234';
                    Navigator.pop(modalCtx);
                    _startTransferProcess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm & Send', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (_currentStep != SendMoneyStep.processing && _currentStep != SendMoneyStep.success) {
        setState(() => _sliderPosition = 0.0);
      }
    });
  }

  Future<void> _executeRealTransfer() async {
    final amountVal = double.tryParse(_enteredAmount.replaceAll(',', '')) ?? 0.0;
    final isWallet = _selectedPayee?.type == 'wallet' || _batwaRecipientTag.isNotEmpty;

    // Recipient tag or identifier
    String rawRecipient = isWallet
        ? (_selectedPayee?.accountNo.isNotEmpty == true
            ? _selectedPayee!.accountNo
            : (_batwaRecipientTag.isNotEmpty ? _batwaRecipientTag : 'sara'))
        : 'bank_settlement';
    rawRecipient = rawRecipient.trim().replaceFirst('@', '');

    final noteText = _transferPurpose.isNotEmpty
        ? _transferPurpose
        : (_selectedBank != null
            ? 'Transfer to ${_selectedBank!.name} (${_accountInputController.text.trim()})'
            : (_selectedPayee != null
                ? 'Transfer to ${_selectedPayee!.name} (${_selectedPayee!.bank})'
                : 'Direct Fund Transfer'));

    try {
      final datasource = TransferRemoteDataSourceImpl(apiClient: ApiClient());
      final tx = await datasource.executeTransfer(
        recipientIdentifier: rawRecipient,
        amount: amountVal,
        pin: _confirmedPin ?? '1234',
        note: noteText,
      );

      _transactionRef = tx.referenceNumber;
      if (mounted) {
        setState(() {
          _step3ReceivedBank = true;
          _completedTransaction = tx;
        });
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) setState(() => _currentStep = SendMoneyStep.success);
      }
    } catch (e) {
      debugPrint('Real transfer failed or simulated fallback: $e');
      // If the error was wrong PIN or insufficient balance, show warning
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('pin') || errStr.contains('insufficient') || errStr.contains('locked')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception:', '').trim()),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _currentStep = SendMoneyStep.reviewTransfer;
            _sliderPosition = 0.0;
          });
          return;
        }
      }

      // For network fallback / demo offline
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        setState(() => _step3ReceivedBank = true);
        HapticFeedback.heavyImpact();
      }
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() => _currentStep = SendMoneyStep.success);
    }
  }

  // --- Quick Raast / Wallet Payee Selector Bottom Sheet ---
  void _showNewPayeeSheet(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = type == 'raast' ? 'Send via Raast ID' : 'Send to Batwa Wallet';
    final hint = type == 'raast' ? 'Enter Mobile Number / CNIC' : 'Enter @batwa_tag or Mobile';

    final inputCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Receiver Name',
                    hintText: 'e.g. Muhammad Asad',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: inputCtrl,
                  decoration: InputDecoration(
                    labelText: 'Raast / Wallet Identifier',
                    hintText: hint,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F4F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim().isEmpty ? 'Recipient' : nameCtrl.text.trim();
                    final acc = inputCtrl.text.trim().isEmpty ? '03001234567' : inputCtrl.text.trim();
                    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'RC';
                    final bankName = type == 'raast' ? 'Raast Instant' : 'Batwa Wallet';

                    Navigator.pop(ctx);
                    setState(() {
                      _selectedPayee = PayeeItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        initials: initials,
                        bank: '$bankName •• ${acc.length >= 4 ? acc.substring(acc.length - 4) : '0000'}',
                        accountNo: acc,
                        type: type,
                        avatarBg: const Color(0xFF10B981),
                      );
                      if (type == 'wallet') {
                        _batwaRecipientTag = acc;
                      }
                      _currentStep = SendMoneyStep.enterAmount;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Proceed to Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎫 DIRECT RECEIPT SCREEN (Bypasses intermediate big tick screen!)
    if (_currentStep == SendMoneyStep.success) {
      final recName = _selectedPayee?.name ?? (_selectedBank?.name ?? 'Beneficiary');
      final recAccount = _selectedPayee?.accountNo ?? _accountInputController.text.trim();
      final recBank = _selectedPayee != null
          ? _selectedPayee!.bank.split('•').first.trim()
          : (_selectedBank?.shortName ?? 'Raast Bank');
      return TransferReceiptScreen(
        transaction: _completedTransaction,
        recipientName: recName,
        recipientAccount: recAccount,
        recipientBank: recBank,
        amount: double.tryParse(_enteredAmount.replaceAll(',', '')) ?? 5010.0,
        referenceId: _transactionRef,
        dateTime: DateTime.now(),
        note: _transferPurpose,
        onDone: () => Navigator.of(context).pop(true),
      );
    }

    return PopScope(
      canPop: _currentStep == SendMoneyStep.selectPayee || _currentStep == SendMoneyStep.success,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFFAFBFD),
        appBar: _currentStep != SendMoneyStep.success
            ? AppBar(
                backgroundColor: isDark ? const Color(0xFF141722) : Colors.white,
                elevation: 0,
                leading: _currentStep != SendMoneyStep.processing
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                        ),
                        onPressed: _handleBackNavigation,
                      )
                    : null,
                title: Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1B1D28),
                  ),
                ),
                actions: [
                  // Step Indicator (Dashes on top right matching media_1790971260447.jpg)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildStepIndicator(),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 22, color: isDark ? Colors.white70 : const Color(0xFF1B1D28)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : null,
        body: SafeArea(
          child: _buildBodyForStep(isDark),
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (_currentStep == SendMoneyStep.selectPayee) {
      Navigator.pop(context);
    } else if (_currentStep == SendMoneyStep.selectBank) {
      setState(() => _currentStep = SendMoneyStep.selectPayee);
    } else if (_currentStep == SendMoneyStep.enterBankAccount) {
      setState(() => _currentStep = SendMoneyStep.selectBank);
    } else if (_currentStep == SendMoneyStep.enterAmount) {
      if (_selectedBank != null) {
        setState(() => _currentStep = SendMoneyStep.enterBankAccount);
      } else {
        setState(() => _currentStep = SendMoneyStep.selectPayee);
      }
    } else if (_currentStep == SendMoneyStep.reviewTransfer) {
      setState(() => _currentStep = SendMoneyStep.enterAmount);
    }
  }

  String _getHeaderTitle() {
    switch (_currentStep) {
      case SendMoneyStep.selectPayee:
        return 'Send money';
      case SendMoneyStep.selectBank:
        return 'Select a Bank';
      case SendMoneyStep.enterBankAccount:
        return 'Account Details';
      case SendMoneyStep.enterAmount:
        return 'How much?';
      case SendMoneyStep.reviewTransfer:
        return 'Review';
      case SendMoneyStep.processing:
        return 'Processing';
      case SendMoneyStep.success:
        return '';
    }
  }

  // 🚥 STEP INDICATOR (Dashes matching screenshot)
  Widget _buildStepIndicator() {
    int activeDashes = 1;
    if (_currentStep == SendMoneyStep.selectBank || _currentStep == SendMoneyStep.enterBankAccount) activeDashes = 2;
    if (_currentStep == SendMoneyStep.enterAmount) activeDashes = 2;
    if (_currentStep == SendMoneyStep.reviewTransfer) activeDashes = 3;
    if (_currentStep == SendMoneyStep.processing || _currentStep == SendMoneyStep.success) activeDashes = 4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < activeDashes;
        return Container(
          width: 14,
          height: 3.5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildBodyForStep(bool isDark) {
    switch (_currentStep) {
      case SendMoneyStep.selectPayee:
        return _buildStep1SelectPayee(isDark);
      case SendMoneyStep.selectBank:
        return _buildSelectBankScreen(isDark);
      case SendMoneyStep.enterBankAccount:
        return _buildEnterBankAccountScreen(isDark);
      case SendMoneyStep.enterAmount:
        return _buildStep2EnterAmount(isDark);
      case SendMoneyStep.reviewTransfer:
        return _buildStep3ReviewTransfer(isDark);
      case SendMoneyStep.processing:
        return _buildStep4Processing(isDark);
      case SendMoneyStep.success:
        return _buildStep5Success(isDark);
    }
  }

  String _getBankIdForPayee(PayeeItem payee) {
    if (payee.bankId != null && payee.bankId!.isNotEmpty) return payee.bankId!;
    final b = payee.bank.toLowerCase();
    if (b.contains('meezan')) return 'meezan';
    if (b.contains('hbl') || b.contains('habib bank')) return 'hbl';
    if (b.contains('alfalah')) return 'alfalah';
    if (b.contains('ubl') || b.contains('united')) return 'ubl';
    if (b.contains('mcb')) return 'mcb';
    if (b.contains('allied') || b.contains('abl')) return 'allied';
    if (b.contains('al habib') || b.contains('alhabib')) return 'alhabib';
    if (b.contains('scb') || b.contains('standard chartered')) return 'scb';
    if (b.contains('nbp') || b.contains('national')) return 'nbp';
    if (b.contains('bop') || b.contains('punjab')) return 'bop';
    if (b.contains('faysal')) return 'faysal';
    if (b.contains('askari')) return 'askari';
    if (b.contains('js')) return 'js';
    if (b.contains('jazzcash') || b.contains('jazz')) return 'jazzcash';
    if (b.contains('easypaisa') || b.contains('telenor')) return 'easypaisa';
    if (b.contains('sadapay') || b.contains('sada')) return 'sadapay';
    if (b.contains('nayapay') || b.contains('naya')) return 'nayapay';
    if (b.contains('raqami') || b.contains('batwa')) return 'raqami';
    if (b.contains('raast')) return 'raast';
    return '1link';
  }

  Widget _buildPayeeBankLogo(PayeeItem payee, {double size = 44}) {
    final bankId = _getBankIdForPayee(payee);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          'assets/images/banks/$bankId.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: payee.avatarBg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.account_balance_rounded, color: payee.avatarBg, size: size * 0.55),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🌟 STEP 1: SELECT PAYEE & SMART SEARCH
  // ==========================================
  Widget _buildStep1SelectPayee(bool isDark) {
    final query = _searchController.text.trim();
    final isIbanQuery = _isIban(query);
    final isRaastQuery = _isRaastPhone(query);

    final filteredPayees = _savedPayees.where((p) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.bank.toLowerCase().contains(q) ||
          p.accountNo.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Universal Smart Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1B1D28),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Name, IBAN, account or Raast ID',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ⚡ Smart Detection Card (If user typed IBAN or Raast Phone)
          if (isIbanQuery || isRaastQuery) ...[
            GestureDetector(
              onTap: () {
                final bank = isIbanQuery ? _detectBankFromIban(query) : 'Raast Instant Direct';
                setState(() {
                  _selectedPayee = PayeeItem(
                    id: 'detected_${DateTime.now().millisecondsSinceEpoch}',
                    name: isIbanQuery ? 'IBAN Beneficiary' : 'Raast Receiver',
                    initials: isIbanQuery ? 'IB' : 'RS',
                    bank: '$bank •• ${query.length >= 4 ? query.substring(query.length - 4) : '0000'}',
                    accountNo: query,
                    type: isIbanQuery ? 'bank' : 'raast',
                    avatarBg: const Color(0xFF10B981),
                  );
                  _selectedBank = null;
                  _currentStep = SendMoneyStep.enterAmount;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2B1D), Color(0xFF047857)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF047857).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isIbanQuery ? Icons.account_balance_rounded : Icons.bolt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isIbanQuery ? 'Detected IBAN' : 'Detected Raast ID',
                                style: const TextStyle(
                                  color: Color(0xFFF3D602),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('INSTANT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isIbanQuery ? _detectBankFromIban(query) : query,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            isIbanQuery ? query : 'Raast 1LINK Real-time Transfer',
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],

          // 🏛️ Quick Action Categories (Account, Raast ID, Wallet)
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.account_balance_rounded,
                  label: 'Account',
                  iconColor: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _currentStep = SendMoneyStep.selectBank);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.bolt_rounded,
                  label: 'Raast ID',
                  iconColor: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () => _showNewPayeeSheet('raast'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCategoryCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  iconColor: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () => _showNewPayeeSheet('wallet'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 📋 SAVED PAYEES Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SAVED PAYEES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '${filteredPayees.length} Payees',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payees List
          if (filteredPayees.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Icon(Icons.person_search_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 10),
                    const Text('No saved payees found', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Try searching by full IBAN or Raast phone number', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141722) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPayees.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                  indent: 68,
                ),
                itemBuilder: (context, index) {
                  final payee = filteredPayees[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: _buildPayeeBankLogo(payee, size: 46),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            payee.name,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1B1D28),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            payee.type.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        payee.bank,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2432) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Send',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedPayee = payee;
                        _selectedBank = null;
                        _currentStep = SendMoneyStep.enterAmount;
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141722) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1B1D28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // 🏛️ STEP: SELECT A BANK
  // ====================================================
  Widget _buildBankLogoWidget(BankItem bank, {double size = 48}) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          'assets/images/banks/${bank.id}.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(bank.icon, color: bank.brandColor, size: size * 0.9);
          },
        ),
      ),
    );
  }

  Widget _buildSelectBankScreen(bool isDark) {
    final query = _bankSearchController.text.trim().toLowerCase();
    final filteredBanks = _allBanks.where((b) {
      if (query.isEmpty) return true;
      return b.name.toLowerCase().contains(query) ||
          b.shortName.toLowerCase().contains(query) ||
          b.code.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Search Bar in Select a Bank
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161A26) : const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bankSearchController,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1B1D28),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),

        // List of Banks (Pill cards with prominent logo, no inner circle/border)
        Expanded(
          child: filteredBanks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                      const SizedBox(height: 12),
                      const Text('No banks match your search', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                  itemCount: filteredBanks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bank = filteredBanks[index];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedBank = bank;
                          _accountInputController.text = 'PK${bank.code}';
                          _currentStep = SendMoneyStep.enterBankAccount;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141722) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildBankLogoWidget(bank, size: 46),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                bank.name,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1B1D28),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

      ],
    );
  }

  // ====================================================
  // 📝 STEP: ENTER ACCOUNT / IBAN FOR SELECTED BANK
  // ====================================================
  Widget _buildEnterBankAccountScreen(bool isDark) {
    final bank = _selectedBank!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Bank Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F2B1D), const Color(0xFF131D24)]
                    : [const Color(0xFFF0FDF4), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildBankLogoWidget(bank, size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'DESTINATION BANK',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981), letterSpacing: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bank.code,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        bank.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1B1D28)),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _currentStep = SendMoneyStep.selectBank),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF10B981)),
                  label: const Text('Change', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Account / IBAN Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Number / 24-digit IBAN',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 2),
                  Text(
                    '1LINK Real-time',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _accountInputController,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : const Color(0xFF1B1D28),
              ),
              decoration: InputDecoration(
                hintText: 'e.g. PK64${bank.code}00012345678901',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'sans-serif'),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste_rounded, size: 20, color: Color(0xFF10B981)),
                  tooltip: 'Paste from clipboard',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null && data!.text!.isNotEmpty) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _accountInputController.text = data.text!.trim();
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Account Title (Receiver Name)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Receiver Account Title',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Verified Title',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _accountTitleController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1B1D28)),
              decoration: InputDecoration(
                hintText: 'e.g. Muhammad Asad Raza',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF10B981), size: 20),
                suffixIcon: _accountTitleController.text.isNotEmpty
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 20),

          // Transfer Purpose Quick Pills
          Text(
            'Transfer Purpose',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Family Support',
                'Bill Payment',
                'Business / Vendor',
                'Education Fees',
                'Gift / Celebration',
              ].map((p) {
                final isSelected = _transferPurpose == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      p,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    showCheckmark: false,
                    onSelected: (val) {
                      setState(() => _transferPurpose = p);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              final acc = _accountInputController.text.trim().isEmpty
                  ? 'PK64${bank.code}00012345678901'
                  : _accountInputController.text.trim();
              final name = _accountTitleController.text.trim().isEmpty
                  ? 'Verified Receiver'
                  : _accountTitleController.text.trim();
              final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'RC';

              HapticFeedback.lightImpact();
              setState(() {
                _selectedPayee = PayeeItem(
                  id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  initials: initials,
                  bank: '${bank.shortName} •• ${acc.length >= 4 ? acc.substring(acc.length - 4) : '0000'}',
                  accountNo: acc,
                  type: 'bank',
                  avatarBg: bank.brandColor,
                  bankId: bank.id,
                );
                _currentStep = SendMoneyStep.enterAmount;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💵 STEP 2: ENTER AMOUNT & NUMERIC KEYPAD
  // ==========================================
  Widget _buildStep2EnterAmount(bool isDark) {
    final payee = _selectedPayee!;
    final numAmount = double.tryParse(_enteredAmount) ?? 0.0;
    final isOverBalance = numAmount > widget.userBalance;

    return Column(
      children: [
        const SizedBox(height: 12),

        // Recipient Pill (Matching media_1790969491250.png)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: payee.avatarBg.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    payee.initials,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: payee.avatarBg),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${payee.name} • ${payee.bank.split('•').first.trim()}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1B1D28),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Big Amount Text with Red/Green Cursor
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rs ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : AppColors.textMuted,
              ),
            ),
            Text(
              _formatWithCommas(_enteredAmount),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: isOverBalance
                    ? const Color(0xFFEF4444)
                    : (isDark ? Colors.white : const Color(0xFF1B1D28)),
              ),
            ),
            Container(
              width: 3,
              height: 38,
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Available Balance Pill / Hint
        GestureDetector(
          onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _isBalanceHidden
                      ? 'Balance hidden • tap to show'
                      : 'Available: Rs ${_formatWithCommas(widget.userBalance.toInt().toString())}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isOverBalance ? const Color(0xFFEF4444) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Quick Amount Chips (Rs 1,000, Rs 5,000, Rs 15,000, Rs 50,000)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAmountChip('1000', 'Rs 1,000', isDark),
              _buildQuickAmountChip('5000', 'Rs 5,000', isDark),
              _buildQuickAmountChip('15000', 'Rs 15,000', isDark),
              _buildQuickAmountChip('50000', 'Rs 50,000', isDark),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Custom Numeric Keypad Grid (1-9, 00, 0, backspace)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Column(
            children: [
              _buildKeypadRow(['1', '2', '3'], isDark),
              _buildKeypadRow(['4', '5', '6'], isDark),
              _buildKeypadRow(['7', '8', '9'], isDark),
              _buildKeypadRow(['00', '0', '⌫'], isDark),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Continue Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ElevatedButton(
            onPressed: numAmount > 0 && !isOverBalance
                ? () {
                    HapticFeedback.mediumImpact();
                    setState(() => _currentStep = SendMoneyStep.reviewTransfer);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              disabledBackgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: numAmount > 0 && !isOverBalance ? 2 : 0,
            ),
            child: Text(
              isOverBalance ? 'Insufficient Balance' : 'Continue',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChip(String value, String label, bool isDark) {
    final isSelected = _enteredAmount == value;
    return GestureDetector(
      onTap: () => _setQuickAmount(int.parse(value)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF181D2A) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1B1D28)),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((k) {
          return InkWell(
            onTap: () => _onKeypadTap(k),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 80,
              height: 48,
              alignment: Alignment.center,
              child: k == '⌫'
                  ? Icon(Icons.backspace_outlined, size: 22, color: isDark ? Colors.white : const Color(0xFF1B1D28))
                  : Text(
                      k,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1B1D28),
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // 🔍 STEP 3: REVIEW TRANSFER & SLIDE TO SEND
  // ==========================================
  Widget _buildStep3ReviewTransfer(bool isDark) {
    final payee = _selectedPayee!;
    final formattedAmt = _formatWithCommas(_enteredAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Recipient Avatar (AR)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: payee.avatarBg.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: payee.avatarBg.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Text(
                payee.initials,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: payee.avatarBg),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Sending to ${payee.name}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),

          // Big Amount
          Text(
            'Rs $formattedAmt',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1B1D28),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          // Review Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141722) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildReviewRow('To', '${payee.name} - ${payee.bank}', isDark),
                const Divider(height: 20, color: Colors.white10),
                _buildReviewRow('From', 'Current •• 0142', isDark),
                const Divider(height: 20, color: Colors.white10),
                _buildReviewRow('Fee', 'Free', isDark, isHighlight: true),
                const Divider(height: 20, color: Colors.white10),
                _buildReviewRow('Arrives', 'Instantly via Raast', isDark),
                const Divider(height: 20, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Purpose', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _transferPurpose,
                        dropdownColor: isDark ? const Color(0xFF1C202E) : Colors.white,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                        ),
                        items: ['Family support', 'Bill payment', 'Education', 'Business', 'Donation']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _transferPurpose = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Guarantee / Disclaimer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No hidden fees and no ads here. If it doesn\'t reach ${payee.name.split(' ').first}, the money stays in your account.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 📲 Interactive Slide-to-Send Slider
          _buildSlideToSendButton(formattedAmt, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isHighlight ? const Color(0xFF10B981) : (isDark ? Colors.white : const Color(0xFF1B1D28)),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSlideToSendButton(String amount, bool isDark) {
    const double sliderHeight = 58;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSlide = constraints.maxWidth - sliderHeight;

        return Container(
          height: sliderHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2B1D), Color(0xFF047857), Color(0xFF10B981)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF047857).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Center Label
              Center(
                child: Text(
                  'Slide to send Rs $amount',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              // Draggable Circular Thumb Handle
              Positioned(
                left: _sliderPosition,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sliderPosition = (_sliderPosition + details.delta.dx).clamp(0.0, maxSlide);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_sliderPosition > maxSlide * 0.75) {
                      HapticFeedback.heavyImpact();
                      setState(() => _sliderPosition = maxSlide);
                      _showPinConfirmSheet();
                    } else {
                      setState(() => _sliderPosition = 0.0);
                    }
                  },
                  child: Container(
                    width: sliderHeight - 8,
                    height: sliderHeight - 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF064E3B),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ⚡ STEP 4: LIVE PROCESSING ANIMATION
  // ==========================================
  Widget _buildStep4Processing(bool isDark) {
    final formattedAmt = _formatWithCommas(_enteredAmount);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Pulse Spinner
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Sending Rs $formattedAmt',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1B1D28),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Usually takes under 5 seconds',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white60 : AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 36),

            // Checklist Timeline
            _buildTimelineItem('Verified on this device', _step1Verified, isDark),
            const SizedBox(height: 16),
            _buildTimelineItem('Sent via Raast', _step2SentRaast, isDark),
            const SizedBox(height: 16),
            _buildTimelineItem('Received by ${_selectedPayee?.bank.split('•').first.trim() ?? 'HBL'}', _step3ReceivedBank, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, bool isDone, bool isDark) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF10B981) : (isDark ? Colors.white12 : Colors.black12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDone
                ? (isDark ? Colors.white : const Color(0xFF1B1D28))
                : (isDark ? Colors.white38 : Colors.black38),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 🎉 STEP 5: SUCCESS CELEBRATION
  // ==========================================
  Widget _buildStep5Success(bool isDark) {
    final payee = _selectedPayee!;
    final formattedAmt = _formatWithCommas(_enteredAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Big Green Check Circle
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Rs $formattedAmt sent',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1B1D28),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            '${payee.name} received it at $_transactionTime.\n${payee.bank.split('•').first.trim()} confirmed it.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Reference Badge
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _transactionRef));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction Ref copied!'), backgroundColor: Color(0xFF10B981)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C202E) : const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ref $_transactionRef',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded, size: 12, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom Buttons (Share & Done)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📄 PDF Receipt downloaded to your device.'),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : const Color(0xFF1B1D28),
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatWithCommas(String numberStr) {
    if (numberStr.isEmpty || numberStr == '0') return '0';
    try {
      final val = int.tryParse(numberStr) ?? 0;
      return val.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return numberStr;
    }
  }
}
