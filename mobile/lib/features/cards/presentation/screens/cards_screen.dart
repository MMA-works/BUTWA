import 'package:flutter/material.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/floating_pill_nav_bar.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/cards/data/cards_remote_datasource.dart';
import 'package:batwa_wallet/features/cards/data/cards_repository_impl.dart';
import 'package:batwa_wallet/features/cards/domain/entities/card_entity.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_event.dart';
import 'package:batwa_wallet/features/cards/presentation/bloc/cards_state.dart';

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
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundSurface,
      body: Stack(
        children: [
          // 🌟 1. HERO TOP BANNER (Signature Light Yellow #F3D602 Radiant Gradient)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.44,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFFF3D602).withValues(alpha: 0.25),
                          const Color(0xFFF3D602).withValues(alpha: 0.12),
                          AppColors.darkBackground.withValues(alpha: 0.0),
                        ]
                      : [
                          const Color(0xFFF3D602),
                          const Color(0xFFF4D916),
                          const Color(0xFFF7E248),
                          const Color(0xFFFAEE88).withValues(alpha: 0.85),
                          const Color(0xFFFCF7CA).withValues(alpha: 0.35),
                          AppColors.backgroundSurface.withValues(alpha: 0.0),
                        ],
                  stops: const [0.0, 0.35, 0.65, 0.82, 0.93, 1.0],
                ),
              ),
            ),
          ),

          // 📱 2. Foreground Content with Custom Top Bar & Cards Body
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Custom Header (Back circle, Title, Add circle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
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
                            border: Border.all(color: AppColors.cardBorder, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy, size: 20),
                          ),
                        ),
                      ),
                      const Text(
                        'Virtual Cards',
                        style: TextStyle(
                          color: AppColors.darkNavy,
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF3D602), Color(0xFFD4B902)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF3D602).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.add_rounded, color: Color(0xFF031E14), size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Body
                Expanded(
                  child: BlocConsumer<CardsBloc, CardsState>(
                    listener: (context, state) {
          if (state is CardsLoadedState && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CardsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CardsLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          List<CardEntity> cards = [];
          bool isActionLoading = false;

          if (state is CardsLoadedState) {
            cards = state.cards;
          } else if (state is CardsActionLoadingState) {
            cards = state.cards;
            isActionLoading = true;
          } else if (state is CardsErrorState) {
            cards = state.cards;
          }

          if (cards.isEmpty) {
            return _buildEmptyCardsView(context);
          }

          if (_selectedCardIndex >= cards.length) {
            _selectedCardIndex = cards.length - 1;
          }

          final currentCard = cards[_selectedCardIndex];

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<CardsBloc>().add(const FetchCardsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Carousel
                  SizedBox(
                    height: 220,
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildCardView(cards[index]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Carousel Page Indicators
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
                                ? AppColors.primary
                                : AppColors.textMuted.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Quick Action Strip (Clean circular bubble buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionBtn(
                          icon: _showCvv ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          label: _showCvv ? 'Hide CVV' : 'Show CVV',
                          onTap: () {
                            setState(() {
                              _showCvv = !_showCvv;
                            });
                          },
                        ),
                        _buildQuickActionBtn(
                          icon: Icons.copy_rounded,
                          label: 'Copy No.',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: currentCard.fullCardNumber ?? currentCard.cardNumber),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Card number copied to clipboard!'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        _buildQuickActionBtn(
                          icon: Icons.add_card_rounded,
                          label: 'Add Card',
                          onTap: () => _showCreateCardBottomSheet(context),
                        ),
                        _buildQuickActionBtn(
                          icon: Icons.account_balance_rounded,
                          label: 'Bank Details',
                          onTap: () => _showBankDetailsSheet(context, currentCard),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Controls Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'CARD SECURITY & CONTROLS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            title: 'Freeze Card',
                            subtitle: currentCard.isFrozen
                                ? 'Card is locked from all transactions'
                                : 'Temporarily lock this virtual card',
                            icon: Icons.ac_unit_rounded,
                            iconColor: currentCard.isFrozen ? Colors.lightBlueAccent : AppColors.primary,
                            value: currentCard.isFrozen,
                            disabled: isActionLoading,
                            onChanged: (val) {
                              context.read<CardsBloc>().add(
                                    ToggleFreezeEvent(cardId: currentCard.id),
                                  );
                            },
                          ),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          _buildSwitchTile(
                            title: 'Online Transactions',
                            subtitle: 'Allow web and in-app merchant payments',
                            icon: Icons.shopping_bag_outlined,
                            iconColor: currentCard.isOnlineEnabled ? AppColors.primary : AppColors.textSecondary,
                            value: currentCard.isOnlineEnabled,
                            disabled: isActionLoading || currentCard.isFrozen,
                            onChanged: (val) {
                              context.read<CardsBloc>().add(
                                    ToggleOnlineEvent(cardId: currentCard.id),
                                  );
                            },
                          ),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
                            ),
                            title: const Text(
                              'Monthly Spending Limit',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                              '\$${currentCard.monthlyLimit.toStringAsFixed(2)} USD',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accent),
                              ),
                              child: const Text('In-House', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
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

          // 🌟 3. Floating Bottom Navigation Dock (Persistent across all tabs!)
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

  Widget _buildCardView(CardEntity card) {
    final bool isFrozen = card.isFrozen;
    final bool isMastercard = card.cardNetwork.toUpperCase().contains('MASTERCARD');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFrozen
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFF042B1D), const Color(0xFF063C28), const Color(0xFF084E35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isFrozen ? const Color(0xFF1E293B) : const Color(0xFF063A27)).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isFrozen ? Colors.lightBlueAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          width: isFrozen ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient Geometric Glow
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: VISA / Mastercard badge & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        isMastercard
                            ? 'assets/images/payment_networks/mastercard.png'
                            : 'assets/images/payment_networks/visa.png',
                        height: isMastercard ? 24 : 16,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          isMastercard ? 'MASTERCARD' : 'VISA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (isFrozen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.lightBlueAccent, width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.ac_unit_rounded, color: Colors.lightBlueAccent, size: 11),
                              SizedBox(width: 4),
                              Text('FROZEN', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Card Number
                  Text(
                    card.cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // Bottom Details: Holder, Expiry, CVV
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD HOLDER',
                            style: TextStyle(color: Color(0xFF8E9584), fontSize: 8.5, letterSpacing: 1, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.cardHolderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(color: Color(0xFF8E9584), fontSize: 8.5, letterSpacing: 1, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${card.expiryMonth}/${card.expiryYear.length >= 4 ? card.expiryYear.substring(2) : card.expiryYear}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
                            style: TextStyle(color: Color(0xFF8E9584), fontSize: 8.5, letterSpacing: 1, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _showCvv ? (card.cvv ?? '•••') : '•••',
                            style: const TextStyle(
                              color: Color(0xFFC3EB54),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required bool disabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: disabled ? null : onChanged,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.accent,
      ),
    );
  }

  Widget _buildEmptyCardsView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Virtual Cards Yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate an instant, Luhn-valid 16-digit virtual card with zero third-party fees.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Issue Instant Card', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => _showCreateCardBottomSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCardBottomSheet(BuildContext parentContext) {
    String selectedNetwork = 'MASTERCARD_BLACK';

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Issue New Virtual Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Instantly generated with Mod-10 Luhn check validation.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Option 1: Mastercard Black
                  _buildNetworkSelector(
                    title: 'Mastercard Black Edition',
                    subtitle: 'Prefix 5425 • Premium Limit \$5,000',
                    icon: Icons.credit_card_rounded,
                    isSelected: selectedNetwork == 'MASTERCARD_BLACK',
                    onTap: () {
                      setModalState(() {
                        selectedNetwork = 'MASTERCARD_BLACK';
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Option 2: Visa Platinum
                  _buildNetworkSelector(
                    title: 'Visa Platinum Edition',
                    subtitle: 'Prefix 4532 • Standard Limit \$5,000',
                    icon: Icons.payment_rounded,
                    isSelected: selectedNetwork == 'VISA_PLATINUM',
                    onTap: () {
                      setModalState(() {
                        selectedNetwork = 'VISA_PLATINUM';
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(modalContext);
                        parentContext.read<CardsBloc>().add(
                              GenerateCardEvent(cardNetwork: selectedNetwork),
                            );
                      },
                      child: const Text(
                        'Generate Card Now',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNetworkSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
  void _showBankDetailsSheet(BuildContext context, CardEntity card) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Generate IBAN and account number from card details
    final accountNumber = '0${card.id.replaceAll('-', '').substring(0, 10)}';
    final iban = 'PK${card.id.replaceAll('-', '').substring(0, 2).toUpperCase()}RQMI${accountNumber.padLeft(16, '0')}';

    void copyToClipboard(String text, String label) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141722) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF042B1D).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Color(0xFF042B1D), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank Account Details',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Raqami Islamic Digital Bank',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Holder Name
              _buildDetailTile(
                isDark: isDark,
                label: 'Account Holder',
                value: card.cardHolderName,
                icon: Icons.person_rounded,
                onCopy: () => copyToClipboard(card.cardHolderName, 'Account holder name'),
              ),
              const SizedBox(height: 12),

              // Account Number
              _buildDetailTile(
                isDark: isDark,
                label: 'Account Number',
                value: accountNumber,
                icon: Icons.tag_rounded,
                onCopy: () => copyToClipboard(accountNumber, 'Account number'),
              ),
              const SizedBox(height: 12),

              // IBAN
              _buildDetailTile(
                isDark: isDark,
                label: 'IBAN',
                value: iban,
                icon: Icons.credit_score_rounded,
                onCopy: () => copyToClipboard(iban, 'IBAN'),
              ),
              const SizedBox(height: 12),

              // Bank Name
              _buildDetailTile(
                isDark: isDark,
                label: 'Bank',
                value: 'Raqami Islamic Digital Bank',
                icon: Icons.business_rounded,
                onCopy: () => copyToClipboard('Raqami Islamic Digital Bank', 'Bank name'),
              ),

              const SizedBox(height: 20),

              // Copy All Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: const Color(0xFF042B1D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.copy_all_rounded, size: 18),
                  label: const Text('Copy All Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  onPressed: () {
                    final allDetails = '''Account Holder: ${card.cardHolderName}
Account Number: $accountNumber
IBAN: $iban
Bank: Raqami Islamic Digital Bank''';
                    copyToClipboard(allDetails, 'All account details');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D28) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: label == 'IBAN' || label == 'Account Number' ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF242825) // Exact line color #242825
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const double waveWidth = 22.0;
    const double waveHeight = 5.0;
    const double rowSpacing = 16.0;

    for (double y = 4; y < size.height + rowSpacing; y += rowSpacing) {
      final path = Path();
      path.moveTo(-waveWidth, y);
      for (double x = -waveWidth; x < size.width + waveWidth * 2; x += waveWidth) {
        path.lineTo(x + waveWidth / 2, y + waveHeight);
        path.lineTo(x + waveWidth, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
