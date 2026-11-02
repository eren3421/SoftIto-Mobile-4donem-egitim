// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:birlestirme/main.dart';

void main() {
  testWidgets('Vitrin ekrani ve sepet smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that Vitrin screen is loaded.
    expect(find.text('Canlı Vitrin'), findsOneWidget);
    expect(find.text('Sepete ürün ekle (+1)'), findsOneWidget);

    // Tap the add to basket button and trigger a frame.
    await tester.tap(find.text('Sepete ürün ekle (+1)'));
    await tester.pumpAndSettle();

    // Verify that badge displays 1.
    expect(find.text('1'), findsOneWidget);
  });
}
