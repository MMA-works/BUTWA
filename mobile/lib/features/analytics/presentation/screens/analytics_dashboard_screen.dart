import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/utils/currency_formatters.dart';
import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:batwa_wallet/features/analytics/presentation/widgets/set_budget_dialog.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/transaction_entity.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/transfer_receipt_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/widgets/floating_pill_nav_bar.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late DateTime _selectedMonth;
  int _selectedFilterIndex = 2; // 0: Today, 1: Weekly, 2: Monthly, 3: Yearly
  int _selectedBarIndex = 3; // 0..5 (Default: index 3 e.g. APR)
  bool _showTransactionHistory = false; // Toggled via Overview switch button
  String _txFilter = 'ALL'; // ALL, EXPENSE, INFLOW
  double _customGoalTarget = 5000.0;

  // 🌟 SIGNATURE UNIFIED BATWA THEME TOKENS
  static const Color _brandYellow = Color(0xFFF3D602); // Exact #F3D602 Brand Yellow
  static const Color _brandYellowDark = Color(0xFFD4B902);
  static const Color _darkGreenStart = Color(0xFF042B1D); // Signature Dark Emerald Box
  static const Color _darkGreenMid = Color(0xFF063C28);
  static const Color _darkGreenEnd = Color(0xFF084E35);
  static const Color _darkNavy = Color(0xFF1B1D28); // Typography & Icons
  static const Color _accentEmerald = Color(0xFF10B981);
  static const Color _cardBorder = Color(0xFFECEFF2);

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadData();
  }

  String get _periodString => DateFormat('yyyy-MM').format(_selectedMonth);

  void _loadData() {
    context.read<AnalyticsBloc>().add(LoadAnalyticsSummaryEvent(period: _periodString));
  }

  void _openSetBudgetSheet([BudgetEntity? budget, String? categoryCode]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AnalyticsBloc>(),
        child: SetBudgetDialog(
          currentPeriod: _periodString,
          existingBudget: budget,
          initialCategory: categoryCode ?? budget?.category,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }

  // 🌟 Period Data Provider for Responsive & Interactive Metric Changes
  Map<String, dynamic> _getPeriodData(int filterIndex, AnalyticsSummaryEntity summary) {
    switch (filterIndex) {
      case 0: // Today
        return {
          'periodName': 'Today',
          'totalBalance': summary.netSavings,
          'earningPercentage': 8,
          'earningSubtext': 'Your earning today increased by 8% compared to yesterday.',
          'goalCurrent': 850.0,
          'goalTarget': 1000.0,
          'goalProgress': 0.85,
          'totalOutflow': 705.00,
          'debitCardSpend': 410.00,
          'creditCardSpend': 295.00,
          'labels': ['09:00', '12:00', '15:00', '18:00', '21:00', '23:00'],
          'emeraldBlocks': [1, 2, 1, 3, 2, 1],
          'yellowBlocks': [1, 1, 2, 2, 3, 1],
          'barAmounts': ['Rs 45.00', 'Rs 120.00', 'Rs 60.00', 'Rs 210.00', 'Rs 180.00', 'Rs 90.00'],
          'gridLabels': ['Rs 250', 'Rs 200', 'Rs 150', 'Rs 100', 'Rs 50', 'Rs 0'],
          'categoryBreakdown': const [
            CategorySpendingEntity(category: 'FOOD', categoryName: 'Food & Dining', totalAmount: 320.00, percentageOfTotal: 45.4, transactionCount: 2),
            CategorySpendingEntity(category: 'TRAVEL', categoryName: 'Travel & Trips', totalAmount: 240.00, percentageOfTotal: 34.0, transactionCount: 1),
            CategorySpendingEntity(category: 'BILLS_UTILITIES', categoryName: 'Bills & Utilities', totalAmount: 145.00, percentageOfTotal: 20.6, transactionCount: 1),
          ],
        };
      case 1: // Weekly
        return {
          'periodName': 'Weekly',
          'totalBalance': summary.netSavings,
          'earningPercentage': 18,
          'earningSubtext': 'Your weekly earning increased by 18% compared to last week.',
          'goalCurrent': 2400.0,
          'goalTarget': 3000.0,
          'goalProgress': 0.80,
          'totalOutflow': 1840.50,
          'debitCardSpend': 1180.50,
          'creditCardSpend': 660.00,
          'labels': ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
          'emeraldBlocks': [1, 1, 2, 2, 3, 1],
          'yellowBlocks': [2, 3, 1, 2, 2, 4],
          'barAmounts': ['Rs 340.00', 'Rs 520.00', 'Rs 260.00', 'Rs 720.00', 'Rs 690.00', 'Rs 410.00'],
          'gridLabels': ['Rs 800', 'Rs 650', 'Rs 500', 'Rs 350', 'Rs 200', 'Rs 0'],
          'categoryBreakdown': const [
            CategorySpendingEntity(category: 'FOOD', categoryName: 'Food & Dining', totalAmount: 680.00, percentageOfTotal: 36.9, transactionCount: 6),
            CategorySpendingEntity(category: 'SHOPPING', categoryName: 'Shopping & Retail', totalAmount: 520.00, percentageOfTotal: 28.3, transactionCount: 3),
            CategorySpendingEntity(category: 'BILLS_UTILITIES', categoryName: 'Bills & Utilities', totalAmount: 340.50, percentageOfTotal: 18.5, transactionCount: 2),
            CategorySpendingEntity(category: 'TRAVEL', categoryName: 'Travel & Trips', totalAmount: 300.00, percentageOfTotal: 16.3, transactionCount: 4),
          ],
        };
      case 3: // Yearly
        return {
          'periodName': 'Yearly',
          'totalBalance': 124800.00,
          'earningPercentage': 34,
          'earningSubtext': 'Your annual earning increased by 34% compared to previous year.',
          'goalCurrent': 38900.0,
          'goalTarget': 50000.0,
          'goalProgress': 0.77,
          'totalOutflow': 34820.00,
          'debitCardSpend': 22630.00,
          'creditCardSpend': 12190.00,
          'labels': ['2021', '2022', '2023', '2024', '2025', '2026'],
          'emeraldBlocks': [2, 2, 3, 2, 3, 4],
          'yellowBlocks': [1, 2, 2, 3, 3, 2],
          'barAmounts': ['Rs 18,400', 'Rs 24,200', 'Rs 31,500', 'Rs 38,900', 'Rs 44,100', 'Rs 52,800'],
          'gridLabels': ['Rs 55k', 'Rs 45k', 'Rs 35k', 'Rs 25k', 'Rs 15k', 'Rs 0'],
          'categoryBreakdown': const [
            CategorySpendingEntity(category: 'SHOPPING', categoryName: 'Shopping & Retail', totalAmount: 12400.00, percentageOfTotal: 35.6, transactionCount: 42),
            CategorySpendingEntity(category: 'FOOD', categoryName: 'Food & Dining', totalAmount: 9800.00, percentageOfTotal: 28.1, transactionCount: 68),
            CategorySpendingEntity(category: 'BILLS_UTILITIES', categoryName: 'Bills & Utilities', totalAmount: 7200.00, percentageOfTotal: 20.7, transactionCount: 24),
            CategorySpendingEntity(category: 'TRAVEL', categoryName: 'Travel & Trips', totalAmount: 5420.00, percentageOfTotal: 15.6, transactionCount: 19),
          ],
        };
      case 2: // Monthly (Default)
      default:
        final earningPct = summary.savingsRatePercentage.toInt() > 0 ? summary.savingsRatePercentage.toInt() : 24;
        final currentInflow = summary.totalInflow;
        final currentOutflow = summary.totalOutflow;
        return {
          'periodName': 'Monthly',
          'totalBalance': summary.netSavings,
          'earningPercentage': earningPct,
          'earningSubtext': 'Your current month earning increased by $earningPct% compared to last month.',
          'goalCurrent': currentInflow,
          'goalTarget': _customGoalTarget,
          'goalProgress': (currentInflow / _customGoalTarget).clamp(0.0, 1.0),
          'totalOutflow': currentOutflow,
          'debitCardSpend': (currentOutflow * 0.62),
          'creditCardSpend': (currentOutflow * 0.38),
          'labels': ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'],
          'emeraldBlocks': [1, 1, 1, 2, 2, 1],
          'yellowBlocks': [2, 1, 3, 2, 4, 2],
          'barAmounts': ['Rs 1,720.00', 'Rs 2,180.00', 'Rs 3,450.00', 'Rs 4,820.00', 'Rs 6,250.00', 'Rs 3,840.00'],
          'gridLabels': ['Rs 7000', 'Rs 5500', 'Rs 4000', 'Rs 2500', 'Rs 1000', 'Rs 0'],
          'categoryBreakdown': summary.categoryBreakdown.isNotEmpty ? summary.categoryBreakdown : const [
            CategorySpendingEntity(category: 'FOOD', categoryName: 'Food & Dining', totalAmount: 940.50, percentageOfTotal: 28.9, transactionCount: 14),
            CategorySpendingEntity(category: 'SHOPPING', categoryName: 'Shopping & Retail', totalAmount: 1120.00, percentageOfTotal: 34.5, transactionCount: 6),
            CategorySpendingEntity(category: 'BILLS_UTILITIES', categoryName: 'Bills & Utilities', totalAmount: 620.30, percentageOfTotal: 19.1, transactionCount: 3),
            CategorySpendingEntity(category: 'TRAVEL', categoryName: 'Transport & Fuel', totalAmount: 570.00, percentageOfTotal: 17.5, transactionCount: 8),
          ],
        };
    }
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
                          const Color(0xFFF3D602), // Vibrant Brand Yellow #F3D602
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

          // 📱 2. Foreground Content Scrollable
          SafeArea(
            bottom: false,
            child: BlocConsumer<AnalyticsBloc, AnalyticsState>(
              listener: (context, state) {
                if (state is AnalyticsLoaded && state.message != null && state.message!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: _darkGreenStart,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is AnalyticsOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: _darkGreenStart,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _loadData();
                } else if (state is AnalyticsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _brandYellow),
                  );
                }

                AnalyticsSummaryEntity summary;
                if (state is AnalyticsLoaded) {
                  summary = state.summary;
                } else {
                  // Fallback preview data matching Batwa theme
                  summary = const AnalyticsSummaryEntity(
                    monthPeriod: '2026-10',
                    totalInflow: 0.0,
                    totalOutflow: 0.00,
                    netSavings: 0.00,
                    savingsRatePercentage: 24.0,
                    totalTransactionsCount: 18,
                    categoryBreakdown: [
                      CategorySpendingEntity(
                        category: 'FOOD_AND_DINING',
                        categoryName: 'Food & Dining',
                        totalAmount: 940.50,
                        percentageOfTotal: 28.9,
                        transactionCount: 14,
                      ),
                      CategorySpendingEntity(
                        category: 'SHOPPING',
                        categoryName: 'Shopping & Retail',
                        totalAmount: 1120.00,
                        percentageOfTotal: 34.5,
                        transactionCount: 6,
                      ),
                      CategorySpendingEntity(
                        category: 'UTILITIES',
                        categoryName: 'Bills & Utilities',
                        totalAmount: 620.30,
                        percentageOfTotal: 19.1,
                        transactionCount: 3,
                      ),
                      CategorySpendingEntity(
                        category: 'TRANSPORT',
                        categoryName: 'Transport & Fuel',
                        totalAmount: 570.00,
                        percentageOfTotal: 17.5,
                        transactionCount: 8,
                      ),
                    ],
                    activeBudgets: [],
                    dailyTrends: [],
                  );
                }

                return _buildUnifiedBody(summary);
              },
            ),
          ),

          // 🌟 3. Floating Bottom Navigation Dock (Persistent across all tabs!)
          FloatingPillNavBar(
            selectedIndex: 2,
            onTabSelected: (index) {
              if (index == 0) {
                Navigator.of(context).pop();
              } else if (index == 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CardsScreen()),
                );
              } else if (index == 2) {
                // Already on Statistics
              } else if (index == 3) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedBody(AnalyticsSummaryEntity summary) {
    final periodData = _getPeriodData(_selectedFilterIndex, summary);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120), // Generous padding for floating nav bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 Top Navigation Bar: Back Circle, "Statistics", Options Circle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: _darkNavy,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _darkNavy,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showStatisticsOptionsMenu();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: _darkNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // 🌟 4 Period Filter Pills (Today, Weekly, Monthly, Yearly)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildUnifiedFilterPill(0, 'Today'),
                const SizedBox(width: 8),
                _buildUnifiedFilterPill(1, 'Weekly'),
                const SizedBox(width: 8),
                _buildUnifiedFilterPill(2, 'Monthly'),
                const SizedBox(width: 8),
                _buildUnifiedFilterPill(3, 'Yearly'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 🌟 Interactive Dual Metric Cards (Earning & Spending)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟡 Left Card: Earning (Signature Vibrant Brand Yellow)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showEarningGoalSheet(summary, periodData);
                    },
                    child: Container(
                      height: 234,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _brandYellow,
                            _brandYellowDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: _brandYellow.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Card Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 16,
                                      color: Color(0xFF031E14),
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Earning',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF031E14),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF031E14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 14,
                                    color: _brandYellow,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Big Percentage Stat
                          Text(
                            '+${periodData['earningPercentage']}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF031E14),
                              letterSpacing: -1.2,
                              height: 1.0,
                            ),
                          ),

                          // Subtext
                          Text(
                            periodData['earningSubtext'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A2E20),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Goal Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Goal',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF031E14),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'Rs ${(periodData['goalCurrent'] as double).toInt()} / Rs ${(periodData['goalTarget'] as double).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF031E14),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),

                          // 10 Progress Dots (Interactive visual indicator)
                          Row(
                            children: List.generate(10, (index) {
                              final double progress = periodData['goalProgress'] as double;
                              final int activeDots = (progress * 10).round().clamp(1, 10);
                              final isFilled = index < activeDots;
                              return Expanded(
                                child: Container(
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    color: isFilled
                                        ? const Color(0xFF031E14)
                                        : Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 🟢 Right Card: Spending (Signature Dark Green Box Container)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showSpendingAnalysisSheet(summary, periodData);
                    },
                    child: Container(
                      height: 234,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _darkGreenStart,
                            _darkGreenMid,
                            _darkGreenEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _accentEmerald.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _darkGreenStart.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Card Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.call_made_rounded,
                                      size: 16,
                                      color: _brandYellow,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Spending',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _brandYellow,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Big Spending Amount
                          Text(
                            'Rs ${(periodData['totalOutflow'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Spider / Radar Polygon Chart in Brand Colors
                          SizedBox(
                            height: 82,
                            child: Center(
                              child: CustomPaint(
                                size: const Size(116, 82),
                                painter: _MiniSpiderChartPainter(),
                              ),
                            ),
                          ),

                          // Legend Row (Debit Card Cyan, Credit Card Yellow)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00D2D3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Debit Rs ${(periodData['debitCardSpend'] as double? ?? 12450).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: _brandYellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Credit Rs ${(periodData['creditCardSpend'] as double? ?? 5950).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 🌟 Overview Section Header with Switch Option to Transaction History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _showTransactionHistory ? 'Transaction History' : 'Overview',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _darkNavy,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),

                // 🔄 Switch Option Button (Toggles between Chart View and Transaction History)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showTransactionHistory = !_showTransactionHistory;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: _showTransactionHistory
                          ? const LinearGradient(
                              colors: [_brandYellow, _brandYellowDark],
                            )
                          : const LinearGradient(
                              colors: [_darkGreenStart, _darkGreenMid],
                            ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _showTransactionHistory
                            ? _brandYellow
                            : _brandYellow.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _showTransactionHistory
                              ? _brandYellow.withValues(alpha: 0.4)
                              : _darkGreenStart.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showTransactionHistory
                              ? Icons.bar_chart_rounded
                              : Icons.tune_rounded,
                          size: 16,
                          color: _showTransactionHistory
                              ? const Color(0xFF031E14)
                              : _brandYellow,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showTransactionHistory ? 'View Chart' : 'History',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: _showTransactionHistory
                                ? const Color(0xFF031E14)
                                : _brandYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🌟 Overview Card Container (Crisp White Card Container matching Recent Activity)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _cardBorder,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: _showTransactionHistory
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _buildUnifiedOverviewChartView(summary, periodData),
                secondChild: _buildUnifiedTransactionHistoryView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Filter Pill (White with border when unselected, Brand Yellow glow when selected)
  Widget _buildUnifiedFilterPill(int index, String title) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedFilterIndex = index;
            // Bound selected bar index within valid range
            _selectedBarIndex = _selectedBarIndex.clamp(0, 5);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [_brandYellow, _brandYellowDark],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? _brandYellow : _cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: _brandYellow.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? const Color(0xFF031E14) : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 Unified Overview Chart View in Crisp White Container
  Widget _buildUnifiedOverviewChartView(
    AnalyticsSummaryEntity summary,
    Map<String, dynamic> periodData,
  ) {
    final labels = periodData['labels'] as List<String>;
    final emeraldBlocks = periodData['emeraldBlocks'] as List<int>;
    final yellowBlocks = periodData['yellowBlocks'] as List<int>;
    final barAmounts = periodData['barAmounts'] as List<String>;
    final gridLabels = periodData['gridLabels'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Balance & Legends
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rs ${((periodData['totalBalance'] as double?) ?? summary.netSavings).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _darkNavy,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Debit Spending',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _brandYellow,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Credit Spending',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _darkGreenStart,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 🌟 FULLY RESPONSIVE & INTERACTIVE STACKED BAR CHART WITH MOVING TOOLTIP
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth - 57;
            final slotWidth = chartWidth / labels.length;
            final safeIndex = _selectedBarIndex.clamp(0, labels.length - 1);
            final targetCenter = 45.0 + (safeIndex * slotWidth) + (slotWidth / 2);
            const tooltipWidth = 78.0;
            final tooltipLeft = (targetCenter - (tooltipWidth / 2)).clamp(40.0, constraints.maxWidth - tooltipWidth - 4);

            final selEmerald = emeraldBlocks[safeIndex];
            final selYellow = yellowBlocks[safeIndex];
            final totalBlocks = selEmerald + selYellow;

            // Height is 196. Each block is 12px + 3.5px margin = 15.5px. Label row is 22px.
            final selectedBarTop = 196.0 - (22.0 + (totalBlocks * 15.5));
            const badgeContentHeight = 28.0;
            final dottedLineHeight = (selectedBarTop - (6.0 + badgeContentHeight)).clamp(6.0, 150.0);

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final relX = details.localPosition.dx - 45.0;
                if (relX >= 0 && relX < chartWidth) {
                  final newIndex = (relX / slotWidth).floor().clamp(0, labels.length - 1);
                  if (newIndex != _selectedBarIndex) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedBarIndex = newIndex;
                    });
                  }
                }
              },
              child: SizedBox(
                height: 196,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Grid Background Lines
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final gLabel in gridLabels) _UnifiedGridLine(label: gLabel),
                      ],
                    ),

                    // Stacked Block Bars for the 6 slots
                    Positioned.fill(
                      left: 45,
                      right: 12,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(labels.length, (i) {
                          return Expanded(
                            child: _buildUnifiedStackedBar(
                              labels[i],
                              emeraldBlocks: emeraldBlocks[i],
                              yellowBlocks: yellowBlocks[i],
                              isTarget: _selectedBarIndex == i,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedBarIndex = i;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),

                    // 🏷️ Dynamic & Responsive Floating Tooltip Badge
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      top: 6,
                      left: tooltipLeft,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showBarDetailDialog(
                            labels[_selectedBarIndex],
                            barAmounts[_selectedBarIndex],
                            emeraldBlocks[_selectedBarIndex],
                            yellowBlocks[_selectedBarIndex],
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: tooltipWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: _darkGreenStart,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _brandYellow,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _brandYellow.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  barAmounts[_selectedBarIndex],
                                  style: const TextStyle(
                                    color: _brandYellow,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(8, 4),
                              painter: _TrianglePainter(color: _darkGreenStart),
                            ),
                            // Dotted Vertical Pointer Line dynamically stretching to the top of the selected bar
                            SizedBox(
                              height: dottedLineHeight,
                              child: CustomPaint(
                                size: Size(2, dottedLineHeight),
                                painter: _DottedLinePainter(color: _brandYellow),
                              ),
                            ),
                            // Glowing Accent Anchor Dot right on top of the bar
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _brandYellow,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _brandYellow.withValues(alpha: 0.8),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 26),

        // 🌟 Active Monthly Budgets Tracker
        _buildActiveBudgetsSection(summary),

        const SizedBox(height: 10),

        // Category Breakdown Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _darkNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openSetBudgetSheet();
              },
              behavior: HitTestBehavior.opaque,
              child: const Text(
                '+ Add Budget',
                style: TextStyle(
                  color: _brandYellowDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 🌟 Interactive Category Breakdown Tiles (Tap to view details modal)
        ...((periodData['categoryBreakdown'] as List<CategorySpendingEntity>?) ?? summary.categoryBreakdown).map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showCategoryDetailsSheet(cat);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _darkGreenStart,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _brandYellow.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(cat.category),
                          color: _brandYellow,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cat.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: _darkNavy,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cat.percentageOfTotal.toStringAsFixed(1)}% of total • ${cat.transactionCount} transactions',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs ${cat.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: _darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 🌟 Active Monthly Budgets Section with Live Limits, Spend, and Alerts
  Widget _buildActiveBudgetsSection(AnalyticsSummaryEntity summary) {
    final budgets = summary.activeBudgets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Monthly Budgets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _brandYellow.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${budgets.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openSetBudgetSheet();
              },
              behavior: HitTestBehavior.opaque,
              child: const Text(
                '+ Set Budget',
                style: TextStyle(
                  color: _brandYellowDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (budgets.isEmpty)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _openSetBudgetSheet();
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _darkGreenStart,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_chart_rounded, color: _brandYellow, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Active Budgets for this Month',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _darkNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap here to set category spending limits.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _brandYellowDark),
                ],
              ),
            ),
          )
        else
          ...budgets.map((b) {
            final double pct = (b.percentageUsed / 100.0).clamp(0.0, 1.0);
            final bool isExceeded = b.isExceeded;
            final bool isAlert = b.isAlertTriggered;

            Color progressColor = _accentEmerald;
            if (isExceeded) {
              progressColor = const Color(0xFFEF4444);
            } else if (isAlert) {
              progressColor = const Color(0xFFF59E0B);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openSetBudgetSheet(b, b.category);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isExceeded
                          ? Colors.red.shade300
                          : (isAlert ? Colors.amber.shade300 : _cardBorder),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _darkGreenStart,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_getCategoryIcon(b.category), color: _brandYellow, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatCategoryLabel(b.category),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: _darkNavy,
                                      ),
                                    ),
                                    Text(
                                      'Rs ${b.monthlyLimit.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: _darkNavy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Spent Rs ${b.spentAmount.toStringAsFixed(0)} (${b.percentageUsed.toStringAsFixed(0)}%)',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isExceeded ? Colors.red.shade700 : AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      isExceeded
                                          ? 'Exceeded by Rs ${(b.spentAmount - b.monthlyLimit).toStringAsFixed(0)}'
                                          : 'Rs ${b.remainingAmount.toStringAsFixed(0)} left',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isExceeded ? Colors.red.shade700 : _accentEmerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
      ],
    );
  }

  // 🌟 Unified Transaction History View inside Crisp White Container
  Widget _buildUnifiedTransactionHistoryView() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        List<TransactionEntity> transactions = [];
        String currentWalletTag = 'me';

        if (walletState is WalletLoaded) {
          transactions = walletState.transactions;
          currentWalletTag = walletState.wallet.walletTag;
        }

        final filteredList = transactions.where((tx) {
          final isCredit = tx.transactionType == 'TOPUP' || tx.destinationWalletTag == currentWalletTag;
          if (_txFilter == 'EXPENSE') return !isCredit;
          if (_txFilter == 'INFLOW') return isCredit;
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips (All, Spending, Inflows)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildUnifiedHistoryFilterChip('ALL', 'All Activity'),
                  const SizedBox(width: 8),
                  _buildUnifiedHistoryFilterChip('EXPENSE', 'Spending'),
                  const SizedBox(width: 8),
                  _buildUnifiedHistoryFilterChip('INFLOW', 'Inflows'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (filteredList.isEmpty)
              _buildUnifiedEmptyHistoryState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length > 8 ? 8 : filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tx = filteredList[index];
                  final isCredit = tx.transactionType == 'TOPUP' || tx.destinationWalletTag == currentWalletTag;

                  IconData txIcon;
                  if (tx.transactionType == 'TOPUP') {
                    txIcon = Icons.account_balance_rounded;
                  } else if (tx.description?.toLowerCase().contains('coffee') == true ||
                      tx.description?.toLowerCase().contains('food') == true) {
                    txIcon = Icons.restaurant_rounded;
                  } else if (isCredit) {
                    txIcon = Icons.arrow_downward_rounded;
                  } else {
                    txIcon = Icons.call_made_rounded;
                  }

                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TransferReceiptScreen(transaction: tx),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Squircle Avatar in Dark Forest + Yellow
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _darkGreenStart,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isCredit
                                    ? _brandYellow.withValues(alpha: 0.4)
                                    : Colors.white12,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                txIcon,
                                color: isCredit ? _brandYellow : Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title & Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.transactionType == 'TOPUP'
                                      ? 'Account Top-Up'
                                      : (isCredit
                                          ? 'From @${tx.sourceWalletTag}'
                                          : (tx.description != null && tx.description!.isNotEmpty
                                              ? tx.description!
                                              : 'To @${tx.destinationWalletTag}')),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _darkNavy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatShortDate(tx.createdAt),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Amount & Status
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? '+' : '-'}Rs ${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isCredit ? _accentEmerald : const Color(0xFFE11D48),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? _accentEmerald.withValues(alpha: 0.12)
                                      : Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tx.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: isCredit ? _accentEmerald : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildUnifiedHistoryFilterChip(String filterKey, String label) {
    final isSelected = _txFilter == filterKey;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _txFilter = filterKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _brandYellow : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _brandYellow : _cardBorder,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _brandYellow.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF031E14) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedEmptyHistoryState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              shape: BoxShape.circle,
              border: Border.all(color: _cardBorder),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No transactions in this filter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Interactive Segmented Stacked Bar Column for Month
  Widget _buildUnifiedStackedBar(
    String label, {
    required int emeraldBlocks,
    required int yellowBlocks,
    required bool isTarget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isTarget ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Yellow Blocks (Top - Debit)
            for (int i = 0; i < yellowBlocks; i++)
              Container(
                width: 17,
                height: 12,
                margin: const EdgeInsets.only(bottom: 3.5),
                decoration: BoxDecoration(
                  color: _brandYellow,
                  borderRadius: BorderRadius.circular(4.5),
                  boxShadow: [
                    if (isTarget && i == yellowBlocks - 1)
                      BoxShadow(
                        color: _brandYellow.withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                  ],
                ),
              ),

            // Dark Emerald Blocks (Bottom - Credit)
            for (int i = 0; i < emeraldBlocks; i++)
              Container(
                width: 17,
                height: 12,
                margin: const EdgeInsets.only(bottom: 3.5),
                decoration: BoxDecoration(
                  color: _darkGreenStart,
                  borderRadius: BorderRadius.circular(4.5),
                  border: isTarget
                      ? Border.all(
                          color: _brandYellow.withValues(alpha: 0.6),
                          width: 1,
                        )
                      : null,
                ),
              ),

            const SizedBox(height: 8),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isTarget ? 11 : 10,
                fontWeight: isTarget ? FontWeight.w900 : FontWeight.w700,
                color: isTarget ? _darkNavy : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Interactive Sheet 1: Earning Goal Inspector & Adjuster
  void _showEarningGoalSheet(AnalyticsSummaryEntity summary, Map<String, dynamic> periodData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        double currentGoal = _customGoalTarget;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double currentInflow = periodData['goalCurrent'] as double;
            final double progress = (currentInflow / currentGoal).clamp(0.0, 1.0);
            return Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Savings & Earning Goal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _darkNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _brandYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}% Done',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF031E14),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your ${periodData['periodName']} earning progress against your savings target.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFF1F3F5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_brandYellow),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Current: Rs ${currentInflow.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _darkNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Target: \$${currentGoal.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _darkNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Text(
                    'Quick Goal Presets',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _darkNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [2500.0, 5000.0, 7500.0, 10000.0].map((preset) {
                      final isSelected = currentGoal == preset;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() => currentGoal = preset);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? _darkGreenStart : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? _brandYellow : _cardBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '\$${preset.toInt()}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? _brandYellow : _darkNavy,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _customGoalTarget = currentGoal;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Earning target updated to \$${currentGoal.toInt()}'),
                          backgroundColor: _darkGreenStart,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandYellow,
                      foregroundColor: const Color(0xFF031E14),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Goal Target',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
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

  // 🌟 Interactive Sheet 2: Spending Analysis Inspector
  void _showSpendingAnalysisSheet(AnalyticsSummaryEntity summary, Map<String, dynamic> periodData) {
    final double totalOutflow = periodData['totalOutflow'] as double;
    final double debitSpend = periodData['debitCardSpend'] as double;
    final double creditSpend = periodData['creditCardSpend'] as double;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Spending Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _darkNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _darkGreenStart,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Rs ${totalOutflow.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _brandYellow,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Distribution of expenses for ${periodData['periodName']} across payment methods.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Debit Card Breakdown Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D2D3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Debit Card Spending',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _darkNavy,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${debitSpend.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: _darkNavy,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Credit Card Breakdown Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _brandYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Credit Card Spending',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _darkNavy,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${creditSpend.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: _darkNavy,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openSetBudgetSheet();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreenStart,
                  foregroundColor: _brandYellow,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Set Budget Limit',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🌟 Interactive Sheet 3: Category Details & Transactions
  void _showCategoryDetailsSheet(CategorySpendingEntity cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _darkGreenStart,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _brandYellow.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(cat.category),
                        color: _brandYellow,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.categoryName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _darkNavy,
                          ),
                        ),
                        Text(
                          '${cat.percentageOfTotal.toStringAsFixed(1)}% of total monthly spend',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs ${cat.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryMetricStat('Transactions', '${cat.transactionCount}'),
                    _buildCategoryMetricStat('Avg / Tx', 'Rs ${(cat.totalAmount / (cat.transactionCount > 0 ? cat.transactionCount : 1)).toStringAsFixed(0)}'),
                    _buildCategoryMetricStat('Share', '${cat.percentageOfTotal.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openSetBudgetSheet(null, cat.category);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandYellow,
                  foregroundColor: const Color(0xFF031E14),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Set ${cat.categoryName} Budget',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryMetricStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: _darkNavy,
          ),
        ),
      ],
    );
  }

  // 🌟 Interactive Dialog 4: Bar Details
  void _showBarDetailDialog(String label, String amount, int emeraldBlocks, int yellowBlocks) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$label Activity',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _darkNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _darkGreenStart,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        amount,
                        style: const TextStyle(
                          color: _brandYellow,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Activity in $label includes $yellowBlocks debit card spending blocks and $emeraldBlocks credit card blocks.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _darkNavy,
                          side: const BorderSide(color: _cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _showTransactionHistory = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandYellow,
                          foregroundColor: const Color(0xFF031E14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'View History',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌟 Interactive Menu 5: Top Right Options Menu
  void _showStatisticsOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _brandYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.download_rounded, color: Color(0xFF031E14), size: 20),
                ),
                title: const Text('Download Monthly Statement', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Monthly statement downloaded to device'),
                      backgroundColor: _darkGreenStart,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _darkGreenStart.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: _darkGreenStart, size: 20),
                ),
                title: const Text('Manage Budgets', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _openSetBudgetSheet();
                },
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: _darkNavy, size: 20),
                ),
                title: const Text('View All Transactions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _showTransactionHistory = true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD':
      case 'FOOD_AND_DINING':
        return Icons.restaurant_rounded;
      case 'SHOPPING':
        return Icons.shopping_bag_rounded;
      case 'ENTERTAINMENT':
        return Icons.movie_rounded;
      case 'BILLS_UTILITIES':
      case 'UTILITIES':
        return Icons.receipt_long_rounded;
      case 'TRANSFERS':
        return Icons.swap_horiz_rounded;
      case 'HEALTH':
        return Icons.favorite_rounded;
      case 'EDUCATION':
        return Icons.school_rounded;
      case 'TRAVEL':
      case 'TRANSPORT':
        return Icons.flight_takeoff_rounded;
      case 'INVESTMENT':
        return Icons.trending_up_rounded;
      case 'GENERAL':
      default:
        return Icons.category_rounded;
    }
  }

  String _formatCategoryLabel(String code) {
    switch (code) {
      case 'FOOD':
      case 'FOOD_AND_DINING':
        return 'Food & Dining';
      case 'SHOPPING':
        return 'Shopping & Retail';
      case 'ENTERTAINMENT':
        return 'Entertainment';
      case 'BILLS_UTILITIES':
      case 'UTILITIES':
        return 'Bills & Utilities';
      case 'TRANSFERS':
        return 'Transfers';
      case 'HEALTH':
        return 'Health & Care';
      case 'EDUCATION':
        return 'Education';
      case 'TRAVEL':
      case 'TRANSPORT':
        return 'Travel & Trips';
      case 'INVESTMENT':
        return 'Investments';
      case 'GENERAL':
      default:
        return 'General Expenses';
    }
  }
}

// 🌟 Grid Lines Helper
class _UnifiedGridLine extends StatelessWidget {
  final String label;
  const _UnifiedGridLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFF1F3F5),
          ),
        ),
      ],
    );
  }
}

// 🌟 Triangle Arrow Pointer Helper
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🌟 Dotted Vertical Line Helper
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashHeight = 3.5;
    const dashSpace = 3.5;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🌟 Mini Cyber Radar Polygon Painter (Enlarged, Clear, Multi-Axis)
class _MiniSpiderChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * 0.46;

    final webPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final fillPaint = Paint()
      ..color = const Color(0xFF00D2D3).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF00D2D3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final creditFillPaint = Paint()
      ..color = const Color(0xFFF3D602).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final creditStrokePaint = Paint()
      ..color = const Color(0xFFF3D602)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final dotPaintDebit = Paint()
      ..color = const Color(0xFF00D2D3)
      ..style = PaintingStyle.fill;

    final dotPaintCredit = Paint()
      ..color = const Color(0xFFF3D602)
      ..style = PaintingStyle.fill;

    // 1. Draw 5 radial axis lines from center
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // 2. Draw background concentric webs (3 rings)
    for (double r = 0.35; r <= 1.0; r += 0.32) {
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * math.pi / 5) - math.pi / 2;
        final x = center.dx + (radius * r) * math.cos(angle);
        final y = center.dy + (radius * r) * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, webPaint);
    }

    // 3. Active Data Polygon 1 (Debit Card - Cyan)
    final dataPath1 = Path();
    final dataPoints1 = [0.85, 0.65, 0.92, 0.75, 0.60];
    final List<Offset> points1 = [];
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + (radius * dataPoints1[i]) * math.cos(angle);
      final y = center.dy + (radius * dataPoints1[i]) * math.sin(angle);
      final pt = Offset(x, y);
      points1.add(pt);
      if (i == 0) {
        dataPath1.moveTo(x, y);
      } else {
        dataPath1.lineTo(x, y);
      }
    }
    dataPath1.close();
    canvas.drawPath(dataPath1, fillPaint);
    canvas.drawPath(dataPath1, strokePaint);
    for (final pt in points1) {
      canvas.drawCircle(pt, 2.5, dotPaintDebit);
    }

    // 4. Active Data Polygon 2 (Credit Card - Brand Yellow)
    final dataPath2 = Path();
    final dataPoints2 = [0.55, 0.45, 0.70, 0.52, 0.42];
    final List<Offset> points2 = [];
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + (radius * dataPoints2[i]) * math.cos(angle);
      final y = center.dy + (radius * dataPoints2[i]) * math.sin(angle);
      final pt = Offset(x, y);
      points2.add(pt);
      if (i == 0) {
        dataPath2.moveTo(x, y);
      } else {
        dataPath2.lineTo(x, y);
      }
    }
    dataPath2.close();
    canvas.drawPath(dataPath2, creditFillPaint);
    canvas.drawPath(dataPath2, creditStrokePaint);
    for (final pt in points2) {
      canvas.drawCircle(pt, 2.2, dotPaintCredit);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
