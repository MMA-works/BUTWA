import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/theme/theme_cubit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/send_money_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/balance_card_widget.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/quick_actions_widget.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/deals_slideshow_widget.dart';
import 'package:batwa_wallet/core/utils/user_avatar_helper.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/notched_bottom_sheet_container.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/floating_pill_nav_bar.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/recent_transactions_widget.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';
import 'package:batwa_wallet/features/bills/presentation/screens/bills_hub_screen.dart';
import 'package:batwa_wallet/features/vaults/presentation/screens/vaults_screen.dart';
import 'package:batwa_wallet/features/splits/presentation/screens/splits_hub_screen.dart';
import 'package:batwa_wallet/features/security/presentation/screens/security_settings_screen.dart';
import 'package:batwa_wallet/features/qr/presentation/screens/qr_scanner_screen.dart';
import 'package:batwa_wallet/features/recurring/presentation/screens/recurring_hub_screen.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:batwa_wallet/features/analytics/presentation/widgets/set_budget_dialog.dart';
import 'package:batwa_wallet/features/merchant/presentation/screens/merchant_hub_screen.dart';
import 'package:batwa_wallet/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:batwa_wallet/features/ai_assistant/presentation/screens/batwa_ai_assistant_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const DashboardScreen({super.key, this.onMenuTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  String _currentAvatarUrl = UserAvatarHelper.defaultMaleAvatar;
  String _currentGender = "MALE";

  Future<void> _loadUserAvatar() async {
    final avatar = await UserAvatarHelper.getAvatarUrl();
    final gender = await UserAvatarHelper.getGender();
    if (mounted) {
      setState(() {
        _currentAvatarUrl = avatar;
        _currentGender = gender;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
    context.read<WalletBloc>().add(LoadWalletDataEvent());
  }

  void _showSetBudgetModal(BuildContext context) {
    final period = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SetBudgetDialog(currentPeriod: period),
    );
  }

  void _showMoreServicesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Financial Services & Hubs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Virtual Cards',
                      icon: Icons.credit_card_rounded,
                      color: AppColors.primary,
                      iconColor: AppColors.accent,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Savings Pots',
                      icon: Icons.savings_rounded,
                      color: const Color(0xFFF59E0B),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultsScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Split Bills',
                      icon: Icons.call_split_rounded,
                      color: const Color(0xFF8B5CF6),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitsHubScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Auto-Pay Rules',
                      icon: Icons.autorenew_rounded,
                      color: AppColors.accent,
                      iconColor: AppColors.textPrimary,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringHubScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Merchant POS',
                      icon: Icons.point_of_sale_rounded,
                      color: const Color(0xFF10B981),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantHubScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildServiceBubble(
                      title: 'Security Hub',
                      icon: Icons.shield_rounded,
                      color: AppColors.primary,
                      iconColor: AppColors.accent,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceBubble({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: SpinKitFadingCube(color: AppColors.primary, size: 36));
            }

            if (state is WalletLoaded) {
              return Stack(
                children: [
                  RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      context.read<WalletBloc>().add(LoadWalletDataEvent());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header (Avatar + Name + Theme Mode Toggle + Notification Bubble)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (widget.onMenuTap != null)
                                      GestureDetector(
                                        onTap: widget.onMenuTap,
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          width: 42,
                                          height: 42,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? AppColors.darkSurface
                                                : AppColors.lightSurface,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? AppColors.darkCardBorder
                                                  : AppColors.lightCardBorder,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.grid_view_rounded,
                                              size: 20,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.darkNavy,
                                            ),
                                          ),
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onMenuTap?.call();
                                        _loadUserAvatar();
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: UserAvatarHelper.buildAvatarWidget(
                                        imageUrl: _currentAvatarUrl,
                                        gender: _currentGender,
                                        size: 44,
                                        border: Border.all(color: AppColors.primaryMustard, width: 2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, authState) {
                                        String name = 'Adom Shafi';
                                        if (authState is Authenticated) {
                                          name = authState.user.fullName;
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Welcome Back,',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.lightTextSecondary,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? AppColors.darkTextPrimary
                                                        : AppColors.lightTextPrimary,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('👋', style: TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                
                                // Action Bubbles: Theme Toggle + Notification Bell
                                Row(
                                  children: [
                                    // 🤖 Batwa AI Assistant Bot Mascot
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        final authState = context.read<AuthBloc>().state;
                                        final currentUserName = (authState is Authenticated && authState.user.fullName.isNotEmpty)
                                            ? authState.user.fullName
                                            : 'William Current';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BatwaAiAssistantScreen(
                                              userBalance: state.wallet.balance,
                                              userName: currentUserName,
                                            ),
                                          ),
                                        );
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkSurface
                                              : AppColors.lightSurface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/batwa_ai_bot.png',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.auto_awesome_rounded,
                                              color: Color(0xFF10B981),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ☀️ / 🌙 Theme Toggle Button
                                    BlocBuilder<ThemeCubit, ThemeMode>(
                                      builder: (context, themeMode) {
                                        final isDark = themeMode == ThemeMode.dark ||
                                            (themeMode == ThemeMode.system &&
                                                MediaQuery.of(context).platformBrightness == Brightness.dark);
                                        return GestureDetector(
                                          onTap: () {
                                            context.read<ThemeCubit>().toggleTheme();
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                                size: 20,
                                                color: isDark ? const Color(0xFFFFC107) : AppColors.brandTeal,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Notification Bell Bubble (3D Golden Bell)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                        );
                                      },
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkSurface
                                              : AppColors.lightSurface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? AppColors.darkCardBorder
                                                : AppColors.lightCardBorder,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Center(
                                              child: Image.asset(
                                                'assets/images/notification_3d_bell.png',
                                                width: 25,
                                                height: 25,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.notifications_outlined,
                                                  size: 20,
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? AppColors.darkTextPrimary
                                                      : AppColors.lightTextPrimary,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 7,
                                              right: 7,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? AppColors.darkSurface
                                                        : Colors.white,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // PIN Setup Prompt if needed
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              if (authState is Authenticated && !authState.user.hasPinConfigured) {
                                return Container(
                                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandTealLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shield_rounded, color: AppColors.brandTeal, size: 22),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'Set Up Transfer PIN for instant payments',
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.brandTealDark),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                                          );
                                        },
                                        child: const Text('Setup', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // 🌟 Radiant Mint Balance Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                String name = 'Adom Shafi';
                                if (authState is Authenticated) {
                                  name = authState.user.fullName;
                                }
                                return BalanceCardWidget(
                                  wallet: state.wallet,
                                  isBalanceHidden: state.isBalanceHidden,
                                  userName: name,
                                  onToggleVisibility: () {
                                    context.read<WalletBloc>().add(ToggleBalanceVisibilityEvent());
                                  },
                                  onSetBudget: () => _showSetBudgetModal(context),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 2x2 Action Cards (Send, Receive, Mobile Topup, Pay Bills)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: QuickActionsWidget(
                              onSend: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: state.wallet.balance)),
                                ).then((_) => context.read<WalletBloc>().add(LoadWalletDataEvent()));
                              },
                              onQr: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                                ).then((_) => context.read<WalletBloc>().add(LoadWalletDataEvent()));
                              },
                              onBill: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const BillsHubScreen()),
                                ).then((_) => context.read<WalletBloc>().add(LoadWalletDataEvent()));
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 Quick Send Contacts Carousel
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DealsSlideshowWidget(),
                          ),
                          const SizedBox(height: 14),

                          // 🌟 Signature Notched Bottom Sheet Container
                          NotchedBottomSheetContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recent Activity',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            'See all',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textSecondary),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                RecentTransactionsWidget(
                                  transactions: state.transactions,
                                  currentWalletTag: state.wallet.walletTag,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🌟 Floating Matte Black Bottom Navigation Bar
                  FloatingPillNavBar(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      setState(() => _selectedTabIndex = index);
                      if (index == 1) {
                        _showMoreServicesSheet(context);
                      } else if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
                        ).then((_) {
                          setState(() => _selectedTabIndex = 0);
                          context.read<WalletBloc>().add(LoadWalletDataEvent());
                        });
                      } else if (index == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                        ).then((_) {
                          setState(() => _selectedTabIndex = 0);
                        });
                      }
                    },
                    
                  ),

                  // 🤖 Floating AI Assistant Mascot Shortcut (Bottom Right)
                  Positioned(
                    bottom: 86,
                    right: 18,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        final authState = context.read<AuthBloc>().state;
                        final currentUserName = (authState is Authenticated && authState.user.fullName.isNotEmpty)
                            ? authState.user.fullName
                            : 'William Current';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatwaAiAssistantScreen(
                              userBalance: state.wallet.balance,
                              userName: currentUserName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF191B21)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/batwa_ai_bot.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ask Batwa AI',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1B1D28),
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load wallet data', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<WalletBloc>().add(LoadWalletDataEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}