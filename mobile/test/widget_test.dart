import 'package:flutter_test/flutter_test.dart';
import 'package:batwa_wallet/main.dart';

void main() {
  testWidgets('App starts with BattwaaApp', (WidgetTester tester) async {
    await tester.pumpWidget(const BattwaaApp());
    expect(find.byType(BattwaaApp), findsOneWidget);
  });
}
