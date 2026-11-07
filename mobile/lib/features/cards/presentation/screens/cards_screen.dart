import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/cards/data/cards_remote_datasource.dart';
import 'package:batwa_wallet/features/cards/data/cards_repository_impl.dart';
import 'package:batwa_wallet/features/cards/domain/entities/card_entity.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_event.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_state.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/floating_pill_nav_bar.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardsBloc(
        repository: CardsRepositoryImpl(
          remoteDataSource: CardsRemoteDataSourceImpl(
            apiClient: ApiClient(),
          ),
        ),
      )..add(const FetchCardsEvent()),
      child: const _CardsScreenContent(),
    );
  }
}

class _CardsScreenContent extends StatefulWidget {
  const _CardsScreenContent();

  @override
  State<_CardsScreenContent> createState() => _CardsScreenContentState();
}

class _CardsScreenContentState extends State<_CardsScreenContent> {
  int _selectedCardIndex = 0;
  bool _showCvv = false;
  bool _isOnlineEnabled = true;
  bool _isInternationalEnabled = false;
  bool _isNfcEnabled = true;
  final PageController _pageController = PageController(viewportFraction: 0.82);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFF3D602), size: 18),
            const SizedBox(width: 8),
            Text('$label copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF1B1D28),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 🌟 1. HERO TOP BANNER (Exact Batwa Gold #F3D602 Radiant Gradient)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.46,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFFF3D602).withValues(alpha: 0.30),
                          const Color(0xFFF3D602).withValues(alpha: 0.12),
                          const Color(0xFF0F172A).withValues(alpha: 0.0),
                        ]
                      : [
                          const Color(0xFFF3D602),
                          const Color(0xFFF4D916),
                          const Color(0xFFF7E248),
                          const Color(0xFFFAEE88).withValues(alpha: 0.80),
                          const Color(0xFFFCF7CA).withValues(alpha: 0.25),
                          const Color(0xFFF8FAFC).withValues(alpha: 0.0),
                        ],
                  stops: const [0.0, 0.32, 0.60, 0.78, 0.90, 1.0],
                ),
              ),
            ),
          ),

          // 📱 2. Foreground Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 🌟 Custom Top Header (Back circle, "Virtual Cards", Plus circle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_rounded, color: Color(0xFF07482D), size: 20),
                          ),
                        ),
                      ),
                      const Text(
                        'Virtual Cards',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: -0.4,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showCreateCardBottomSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.add_rounded, color: Color(0xFF07482D), size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🌟 Scrollable Body
                Expanded(
                  child: BlocConsumer<CardsBloc, CardsState>(
                    listener: (context, state) {
                      if (state is CardsLoadedState && state.message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message!),
                            backgroundColor: const Color(0xFF07482D),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      List<CardEntity> cards = [];
                      if (state is CardsLoadedState) {
                        cards = state.cards;
                      } else if (state is CardsActionLoadingState) {
                        cards = state.cards;
                      } else if (state is CardsErrorState) {
                        cards = state.cards;
                      }

                      // Default active card matching user's photo
                      final defaultCard = CardEntity(
                        id: 'card-default-1',
                        cardNumber: '5312 •••• •••• 8821',
                        cardHolderName: 'MUHAMMAD ALI',
                        expiryMonth: '08',
                        expiryYear: '2029',
                        cvv: '742',
                        cardNetwork: 'MASTERCARD_BLACK',
                        status: 'ACTIVE',
                        isOnlineEnabled: true,
                        isInternationalEnabled: false,
                        monthlyLimit: 150000.0,
                        createdAt: DateTime.now(),
                      );

                      if (cards.isEmpty) {
                        cards = [defaultCard];
                      }

                      if (_selectedCardIndex >= cards.length) {
                        _selectedCardIndex = cards.length - 1;
                      }

                      final currentCard = cards[_selectedCardIndex];

                      return RefreshIndicator(
                        color: const Color(0xFF07482D),
                        onRefresh: () async {
                          context.read<CardsBloc>().add(const FetchCardsEvent());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 🌟 1. VERTICAL CARD CAROUSEL (Exact Portrait Card)
                              SizedBox(
                                height: 395,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: cards.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _selectedCardIndex = index;
                                      _showCvv = false;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: _buildVerticalCard(cards[index], isDark),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Carousel Indicators (if multiple cards)
                              if (cards.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    cards.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: _selectedCardIndex == index ? 22 : 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: _selectedCardIndex == index
                                            ? const Color(0xFF07482D)
                                            : Colors.grey.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 18),

                              // 🌟 2. FOUR QUICK ACTION BUTTONS (Exact row from photo)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQuickActionItem(
                                    icon: currentCard.isFrozen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                    label: currentCard.isFrozen ? 'Unfreeze' : 'Freeze Card',
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.read<CardsBloc>().add(
                                            ToggleFreezeEvent(cardId: currentCard.id),
                                          );
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: _showCvv ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    label: _showCvv ? 'Hide CVV' : 'Show CVV',
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _showCvv = !_showCvv;
                                      });
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: Icons.copy_rounded,
                                    label: 'Copy No.',
                                    onTap: () {
                                      _copyToClipboard('5312482019308821', 'Card number');
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: Icons.add_card_rounded,
                                    label: 'Issue Card',
                                    onTap: () => _showCreateCardBottomSheet(context),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // 🌟 3. MONTHLY CARD LIMIT CARD (Exact widget from photo)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.edit_note_rounded,
                                              size: 20,
                                              color: const Color(0xFFF3D602),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Monthly Card Limit',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          'Rs 150,000',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFD4B902),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        height: 7,
                                        width: double.infinity,
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: 0.28,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3D602),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Spent: Rs 42,000 (28%)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          'Available: Rs 108,000',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 🌟 4. CARD SECURITY & CONTROLS (Exact section from photo)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'CARD SECURITY & SETTINGS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingSwitchTile(
                                      icon: Icons.language_rounded,
                                      title: 'Online Payments',
                                      subtitle: 'Enable internet & e-commerce payments',
                                      value: _isOnlineEnabled,
                                      onChanged: (val) {
                                        setState(() => _isOnlineEnabled = val);
                                      },
                                    ),
                                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                    _buildSettingSwitchTile(
                                      icon: Icons.flight_takeoff_rounded,
                                      title: 'International Usage',
                                      subtitle: 'Allow foreign currency transactions',
                                      value: _isInternationalEnabled,
                                      onChanged: (val) {
                                        setState(() => _isInternationalEnabled = val);
                                      },
                                    ),
                                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                    _buildSettingSwitchTile(
                                      icon: Icons.contactless_rounded,
                                      title: 'Contactless NFC',
                                      subtitle: 'Tap & Pay at retail POS terminals',
                                      value: _isNfcEnabled,
                                      onChanged: (val) {
                                        setState(() => _isNfcEnabled = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🌟 3. FLOATING BOTTOM NAVIGATION DOCK (Active Cards Tab)
          FloatingPillNavBar(
            selectedIndex: 1,
            onTabSelected: (index) {
              if (index == 0) {
                Navigator.of(context).pop();
              } else if (index == 1) {
                // Already on Cards
              } else if (index == 2) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
                );
              } else if (index == 3) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  // 🌟 VERTICAL CARD BUILDER (100% 1:1 match with user's photo)
  Widget _buildVerticalCard(CardEntity card, bool isDark) {
    final bool isFrozen = card.isFrozen;

    return Container(
      width: 255,
      height: 390,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isFrozen ? Colors.lightBlueAccent.withValues(alpha: 0.6) : const Color(0xFFF3D602).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFrozen
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF111927), const Color(0xFF0C1322), const Color(0xFF060911)],
        ),
      ),
      child: Stack(
        children: [
          // Ambient Glow Background Accents
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3D602).withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. TOP ROW: Golden Chip + NFC Wave & Mastercard Circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Golden EMV Chip
                        Container(
                          width: 36,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFFC59B27)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFF3D602), width: 0.8),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF8B6508), width: 0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Contactless Wave Icon
                        const RotatedBox(
                          quarterTurns: 1,
                          child: Icon(Icons.wifi_rounded, color: Color(0xFFF3D602), size: 18),
                        ),
                      ],
                    ),

                    // Mastercard Logo (Interlocking Red & Orange Circles)
                    SizedBox(
                      width: 38,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEB001B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 2. BRAND ROW: Batwa Emblem & "BATWA BLACK EDITION"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3D602),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'B',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'BATWA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'BLACK EDITION',
                      style: TextStyle(
                        color: Color(0xFFD4B902),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 3. CARD NUMBER PILL CONTAINER (Centered)
                GestureDetector(
                  onTap: () => _copyToClipboard('5312482019308821', 'Card number'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5312 •••• •••• 8821',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Icon(
                          Icons.copy_rounded,
                          color: Color(0xFFF3D602),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 4. CARD DETAILS: Cardholder, Expiry, CVV
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARDHOLDER',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.cardHolderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '08/29',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _showCvv ? (card.cvv ?? '742') : '•••',
                          style: const TextStyle(
                            color: Color(0xFFF3D602),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 5. BOTTOM ROW: Status Pill & "VIRTUAL CARD"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFrozen ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFrozen ? Colors.lightBlueAccent : const Color(0xFF10B981),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isFrozen ? Colors.lightBlueAccent : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isFrozen ? 'FROZEN' : 'ACTIVE',
                            style: TextStyle(
                              color: isFrozen ? Colors.lightBlueAccent : const Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'VIRTUAL CARD',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 QUICK ACTION BUTTON ITEM
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF07482D), size: 20),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 CARD SECURITY TOGGLE ROW
  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF07482D), size: 19),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF07482D),
            activeTrackColor: const Color(0xFFF3D602),
          ),
        ],
      ),
    );
  }

  // 🌟 ISSUE CARD BOTTOM SHEET
  void _showCreateCardBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Issue New Virtual Card',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Instant Luhn-checked virtual debit card with zero issuance fee.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3D602), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C1322),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.credit_card_rounded, color: Color(0xFFF3D602), size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mastercard Black Edition',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Prefix 5312 • Monthly Limit Rs 150,000',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF07482D), size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(modalContext);
                    parentContext.read<CardsBloc>().add(
                          const GenerateCardEvent(cardNetwork: 'MASTERCARD_BLACK'),
                        );
                  },
                  child: const Text(
                    'Issue Instant Card',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
