import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

class AccountDetailsModal extends StatefulWidget {
  final String fullName;
  final String walletTag;
  final String phoneNumber;
  final String currency;

  const AccountDetailsModal({
    super.key,
    required this.fullName,
    required this.walletTag,
    required this.phoneNumber,
    this.currency = 'PKR',
  });

  static void show(
    BuildContext context, {
    required String fullName,
    required String walletTag,
    required String phoneNumber,
    String currency = 'PKR',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccountDetailsModal(
        fullName: fullName,
        walletTag: walletTag,
        phoneNumber: phoneNumber,
        currency: currency,
      ),
    );
  }

  @override
  State<AccountDetailsModal> createState() => _AccountDetailsModalState();
}

class _AccountDetailsModalState extends State<AccountDetailsModal> {
  String? _copiedKey;

  String get _cleanPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isNotEmpty) {
      if (digits.startsWith('92') && digits.length >= 12) {
        return '0${digits.substring(2)}';
      }
      return digits;
    }
    return '03219876543';
  }

  String get _formattedPhone {
    final p = _cleanPhone;
    if (p.length >= 11) {
      return '${p.substring(0, 4)} ${p.substring(4)}';
    }
    return p;
  }

  String get _accountNumber => _cleanPhone;

  String get _rawIban {
    final phone = _cleanPhone.padLeft(12, '0');
    return 'PK92BATW0142$phone';
  }

  String get _formattedIban {
    final raw = _rawIban;
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  String get _accountTitle =>
      (widget.fullName.trim().isNotEmpty && widget.fullName.trim() != 'Batwa User')
          ? widget.fullName.trim()
          : 'Batwa Account Holder';

  String get _username =>
      (widget.walletTag.trim().isNotEmpty && widget.walletTag.trim() != '@batwa_user')
          ? '@${widget.walletTag.trim().replaceFirst('@', '')}'
          : '@user';

  static const String _bankName = 'BATWA Digital Wallet / Microfinance Bank';

  String get _completeShareText => '''
🏦 BATWA Banking & Account Details:
----------------------------------------
• Bank Name: $_bankName
• Account Title: $_accountTitle
• Username / Tag: $_username
• Account Number: $_accountNumber
• Raast ID: $_accountNumber
• IBAN: $_rawIban
----------------------------------------
(State Bank of Pakistan Licensed EMI • Raast Instant)
'''.trim();

  void _copyToClipboard(String key, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    setState(() => _copiedKey = key);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label copied to clipboard! ✅',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B1D28),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _copiedKey == key) {
        setState(() => _copiedKey = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141722) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E2330) : const Color(0xFFF6F8FA);
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grab Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Banner
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5A623), Color(0xFFFFC043)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF5A623).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_rounded, color: AppColors.darkNavy, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account & Banking Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SBP EMI • RAAST ACTIVE',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Card 1: Account Number
            _buildDetailCard(
              context: context,
              icon: Icons.tag_rounded,
              iconColor: const Color(0xFFF5A623),
              title: 'ACCOUNT NUMBER (RAAST ID)',
              value: _formattedPhone,
              rawValue: _accountNumber,
              copyKey: 'account_number',
              cardBg: cardBg,
              borderColor: borderColor,
              isDark: isDark,
              subtitle: 'Use this mobile number for Raast and Batwa-to-Batwa instant transfers',
            ),
            const SizedBox(height: 12),

            // Card 2: IBAN Number
            _buildDetailCard(
              context: context,
              icon: Icons.account_balance_outlined,
              iconColor: const Color(0xFF00C6FF),
              title: 'IBAN (INTERNATIONAL BANK ACCOUNT NUMBER)',
              value: _formattedIban,
              rawValue: _rawIban,
              copyKey: 'iban',
              cardBg: cardBg,
              borderColor: borderColor,
              isDark: isDark,
              subtitle: 'Send money from any Pakistani bank (HBL, Meezan, Alfalah, etc.) to this IBAN',
              isMonospace: true,
            ),
            const SizedBox(height: 16),

            // Section 3: The Combined All-in-One Shareable Pack
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181C28) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFF5A623).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.share_outlined, color: Color(0xFFF5A623), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Shareable Account Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'All-In-One Pack',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF5A623),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F121C) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      _completeShareText,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11.5,
                        height: 1.45,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _copyToClipboard('complete_pack', _completeShareText, 'Complete Account Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      foregroundColor: AppColors.darkNavy,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _copiedKey == 'complete_pack' ? Icons.check_circle_rounded : Icons.copy_rounded,
                          size: 18,
                          color: AppColors.darkNavy,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _copiedKey == 'complete_pack' ? 'Copied Full Details! ✅' : 'Copy All Account Details',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String rawValue,
    required String copyKey,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
    String? subtitle,
    String? badgeText,
    bool isMonospace = false,
  }) {
    final isCopied = _copiedKey == copyKey;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : Colors.black45,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                          fontFamily: isMonospace ? 'Courier' : null,
                          letterSpacing: isMonospace ? 0.8 : null,
                        ),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyToClipboard(copyKey, rawValue, title),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isCopied
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCopied ? const Color(0xFF10B981) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCopied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 13,
                      color: isCopied
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white70 : const Color(0xFF1B1D28)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCopied ? 'Copied' : 'Copy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isCopied
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white70 : const Color(0xFF1B1D28)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
