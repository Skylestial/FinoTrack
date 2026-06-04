// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:finotrack/app.dart';

void main() {
  testWidgets('Spend summary screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const FinoTrackApp());

    expect(find.text('Spend Summary'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}
