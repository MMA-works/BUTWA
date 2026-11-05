import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:batwa_wallet/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:batwa_wallet/features/analytics/domain/entities/analytics_entities.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:batwa_wallet/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:batwa_wallet/features/wallet/domain/entities/wallet_entity.dart';

// Simple Fake AnalyticsBloc for tests
class FakeAnalyticsBloc extends Cubit<AnalyticsState> implements AnalyticsBloc {
  FakeAnalyticsBloc(super.initialState);

  @override
  void add(AnalyticsEvent event) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Simple Fake WalletBloc for tests
class FakeWalletBloc extends Cubit<WalletState> implements WalletBloc {
  FakeWalletBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AnalyticsDashboardScreen is fully interactive and responsive', (WidgetTester tester) async {
    // Provide a test screen size (e.g. 720 x 1600 typical physical phone)
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const summary = AnalyticsSummaryEntity(
      monthPeriod: '2026-10',
      totalInflow: 2947.0,
      totalOutflow: 3250.80,
      netSavings: 25453.00,
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
      ],
      activeBudgets: [],
      dailyTrends: [],
    );

    const testWallet = WalletEntity(
      id: 'w1',
      walletTag: 'testuser',
      balance: 25453.0,
      currency: 'PKR',
      isActive: true,
      qrCodeData: 'batwa://pay/testuser',
    );

    final analyticsBloc = FakeAnalyticsBloc(const AnalyticsLoaded(summary: summary));
    final walletBloc = FakeWalletBloc(const WalletLoaded(wallet: testWallet, transactions: []));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AnalyticsBloc>.value(value: analyticsBloc),
            BlocProvider<WalletBloc>.value(value: walletBloc),
          ],
          child: const AnalyticsDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Top Title and Period Filter Pills
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);

    // 2. Test Interactivity: Tap Weekly Filter Pill
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('+18%'), findsOneWidget);

    // 3. Test Interactivity: Tap Yearly Filter Pill
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('+34%'), findsOneWidget);

    // 4. Test Interactivity: Tap Monthly Filter Pill (default)
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.text('+24%'), findsOneWidget);

    // 5. Test Bar Chart Month Labels
    expect(find.text('JAN'), findsOneWidget);
    expect(find.text('FEB'), findsOneWidget);
    expect(find.text('MAR'), findsOneWidget);
    expect(find.text('APR'), findsOneWidget);
    expect(find.text('MAY'), findsOneWidget);
    expect(find.text('JUN'), findsOneWidget);

    // 6. Test Bar Chart Tap: Tap 'FEB' bar
    await tester.tap(find.text('FEB'));
    await tester.pumpAndSettle();

    // 7. Test Switch to History Toggle
    expect(find.text('History'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction History'), findsOneWidget);

    // Switch back to Chart View
    await tester.tap(find.text('View Chart'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);

    // 8. Test Earning Card Tap -> Opens Savings & Earning Goal Sheet
    await tester.tap(find.text('Earning'));
    await tester.pumpAndSettle();
    expect(find.text('Savings & Earning Goal'), findsOneWidget);
    expect(find.text('Save Goal Target'), findsOneWidget);

    // Close sheet
    await tester.tap(find.text('Save Goal Target'));
    await tester.pumpAndSettle();

    // 9. Test Category Breakdown Tile Tap -> Opens Category Details Sheet
    await tester.ensureVisible(find.text('Food & Dining').first);
    await tester.tap(find.text('Food & Dining').first);
    await tester.pumpAndSettle();
    expect(find.text('Set Food & Dining Budget'), findsOneWidget);
  });
}
