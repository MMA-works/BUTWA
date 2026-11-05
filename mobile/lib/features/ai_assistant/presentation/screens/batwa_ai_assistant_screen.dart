import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/services/gemini_ai_service.dart';

class BatwaAiAssistantScreen extends StatefulWidget {
  final double userBalance;
  final String userName;

  const BatwaAiAssistantScreen({
    super.key,
    required this.userBalance,
    required this.userName,
  });

  @override
  State<BatwaAiAssistantScreen> createState() => _BatwaAiAssistantScreenState();
}

class _BatwaAiAssistantScreenState extends State<BatwaAiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleSend(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _textController.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': 'Just now',
      });
      _isLoading = true;
    });
    _scrollToBottom();

    // Check for special rich interactive widgets
    final lower = text.toLowerCase();
    await Future.delayed(const Duration(milliseconds: 600));

    if (lower.contains('15,000') || lower.contains('15000') || (lower.contains('ali') && lower.contains('where'))) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': 'Found it. Your Rs 15,000 to Ali Raza reached HBL yesterday at 7:02 PM. Nothing is pending.',
            'type': 'transaction_tracker',
            'time': '7:02 PM',
            'details': {
              'title': 'Rs 15,000 to Ali Raza',
              'bank': 'HBL •• 3301 • Ref RAAST-7729114',
              'steps': [
                {'label': 'Sent from Batwa', 'time': '7:02:11 PM', 'done': true},
                {'label': 'Via Raast', 'time': '7:02:12 PM', 'done': true},
                {'label': 'Received by HBL', 'time': '7:02:14 PM', 'done': true},
              ]
            }
          });
          _isLoading = false;
        });
      }
    } else if (lower.contains('send ali money again')) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': 'Here\'s what I understood. Check it before you confirm.',
            'type': 'transfer_confirm',
            'details': {
              'amount': 'Rs 15,000',
              'recipient': 'Ali Raza',
              'bank': 'HBL •• 3301',
              'from': 'Current •• 0142',
              'fee': 'Free',
            }
          });
          _isLoading = false;
        });
      }
    } else if (lower.contains('k-electric') || lower.contains('bill') || lower.contains('electric')) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': 'I located your upcoming electricity bill. All details are verified with 1LINK:',
            'type': 'bill_card',
            'details': {
              'company': 'K-Electric (KE)',
              'consumerNo': '04000123982',
              'amount': 'Rs 4,820.00',
              'dueDate': '15 Oct 2026',
            }
          });
          _isLoading = false;
        });
      }
    } else {
      // General Gemini / Fallback service response
      final response = await GeminiAiService().sendMessage(
        prompt: text,
        userBalance: widget.userBalance,
        userName: widget.userName,
      );

      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': response,
            'type': 'text',
          });
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141722) : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/batwa_ai_bot.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 22),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batwa AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1B1D28),
              ),
            ),
            const Text(
              'English • اردو • Roman Urdu',
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note_rounded, size: 22, color: isDark ? Colors.white70 : const Color(0xFF1B1D28)),
            onPressed: _resetChat,
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 22, color: isDark ? Colors.white70 : const Color(0xFF1B1D28)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 💬 Chat Body / Landing Screen
          Expanded(
            child: _messages.isEmpty
                ? _buildLandingView(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingBubble(isDark);
                      }
                      return _buildMessageItem(_messages[index], isDark);
                    },
                  ),
          ),

          // ⌨️ Bottom Interactive Input Dock (Full Width)
          _buildInputDock(isDark),
        ],
      ),
    );
  }

  // 🌟 1. LANDING WELCOME VIEW (Clean Headline & Action Cards, No Big Center Circle)
  Widget _buildLandingView(bool isDark) {
    final firstName = widget.userName.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🤖 3D Waving Bot Mascot
          Image.asset(
            'assets/images/batwa_ai_bot.png',
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),

          // Heading
          Text(
            'Hi $firstName, what can I do for you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1B1D28),
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Track transactions, instant bill payments, or ask financial queries in Urdu or English.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Quick Prompt Cards (Signature Green Gradient Style)
          _buildPromptTile(
            icon: Icons.swap_horiz_rounded,
            title: "Where's my Rs 15,000 to Ali?",
            isDark: isDark,
            onTap: () => _handleSend("Where's my Rs 15,000 to Ali?"),
          ),
          const SizedBox(height: 12),
          _buildPromptTile(
            icon: Icons.bolt_rounded,
            title: "Pay my K-Electric bill",
            isDark: isDark,
            onTap: () => _handleSend("Pay my K-Electric bill"),
          ),
          const SizedBox(height: 12),
          _buildPromptTile(
            icon: Icons.sync_rounded,
            title: "Auto-pay bills before due date",
            isDark: isDark,
            onTap: () => _handleSend("Auto-pay bills before due date"),
          ),
          const SizedBox(height: 12),
          _buildPromptTile(
            icon: Icons.content_copy_rounded,
            title: "Why was I charged twice?",
            isDark: isDark,
            onTap: () => _handleSend("Why was I charged twice?"),
          ),
          const SizedBox(height: 12),
          _buildPromptTile(
            icon: Icons.headset_mic_rounded,
            title: "Talk to a person",
            isDark: isDark,
            onTap: () => _handleSend("Talk to a person"),
          ),

          const SizedBox(height: 28),
          Text(
            'Tip: Type anything in Roman Urdu, Urdu, or English to get instant assistance.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPromptTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0F2B1D),
                    const Color(0xFF131D24),
                  ]
                : [
                    const Color(0xFFF0FDF4),
                    Colors.white,
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.2),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.1 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF047857)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF10B981), size: 19),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1B1D28),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  // 💬 2. MESSAGE ITEM RENDERING
  Widget _buildMessageItem(Map<String, dynamic> msg, bool isDark) {
    final isUser = msg['sender'] == 'user';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF047857).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg['text'] as String,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // AI Message
    final type = msg['type'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E2330) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    'assets/images/batwa_ai_bot.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Batwa AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              msg['text'] as String,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1B1D28),
                height: 1.4,
              ),
            ),
          ),

          // Rich Step Tracker
          if (type == 'transaction_tracker') ...[
            const SizedBox(height: 12),
            _buildTransactionTrackerCard(msg['details'] as Map<String, dynamic>, isDark),
          ],

          // Rich Transfer Confirmation
          if (type == 'transfer_confirm') ...[
            const SizedBox(height: 12),
            _buildTransferConfirmCard(msg['details'] as Map<String, dynamic>, isDark),
          ],

          // Rich Bill Card
          if (type == 'bill_card') ...[
            const SizedBox(height: 12),
            _buildBillCard(msg['details'] as Map<String, dynamic>, isDark),
          ],
        ],
      ),
    );
  }

  // 📍 3. INTERACTIVE TRANSACTION TRACKER CARD
  Widget _buildTransactionTrackerCard(Map<String, dynamic> details, bool isDark) {
    final steps = details['steps'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0B2117), const Color(0xFF131B22)]
                    : [const Color(0xFFF0FDF4), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1B1D28),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            details['bank'] as String,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 14),

                // Timeline steps
                for (int i = 0; i < steps.length; i++) ...[
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          steps[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1B1D28),
                          ),
                        ),
                      ),
                      Text(
                        steps[i]['time'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (i < steps.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 2,
                      height: 18,
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Action Buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📄 PDF Receipt saved.'), backgroundColor: Color(0xFF10B981)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(
                  'Share receipt',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B1D28),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _handleSend("Send Ali money again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Send Ali money again', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💳 4. TRANSFER CONFIRMATION CARD
  Widget _buildTransferConfirmCard(Map<String, dynamic> details, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0B2117), const Color(0xFF131B22)]
                : [const Color(0xFFF0FDF4), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Color(0xFF10B981), size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send ${details['amount']} to ${details['recipient']}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B1D28),
                        ),
                      ),
                      Text(
                        details['bank'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('From', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                Text(details['from'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fee', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                Text(details['fee'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔒 Biometric Verified: PKR 15,000 sent to Ali Raza!'),
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Confirm & Pay with Biometrics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚡ 5. BILL DETAILS CARD
  Widget _buildBillCard(Map<String, dynamic> details, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF052E16), Color(0xFF047857), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF047857).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(details['company'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3D602),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('UNPAID', style: TextStyle(color: Color(0xFF1B1D28), fontWeight: FontWeight.w900, fontSize: 9.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(details['amount'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF3D602))),
            const SizedBox(height: 4),
            Text('Consumer: ${details['consumerNo']} • Due: ${details['dueDate']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 K-Electric Bill paid successfully!'), backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3D602),
                foregroundColor: const Color(0xFF1B1D28),
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Pay Rs 4,820 Now', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  // ⏳ 6. LOADING SPINNER BUBBLE
  Widget _buildLoadingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151926) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                ),
                SizedBox(width: 8),
                Text('Thinking...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⌨️ 7. BOTTOM INPUT DOCK
  Widget _buildInputDock(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141722) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F4F9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF1B1D28),
                      ),
                      onSubmitted: _handleSend,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything, e.g. pay my bill',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleSend(_textController.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF047857), Color(0xFF10B981)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 11, color: AppColors.textMuted),
                SizedBox(width: 4),
                Text(
                  'Batwa AI never moves money without your biometric/PIN approval.',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
