// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deneme/main.dart';

void main() {
  testWidgets('App smoke test ve bildirim ozellikleri testi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoftitioFcmUygulamasi());
    await tester.pumpAndSettle();

    expect(find.text('Softito Storage ve Fcm Çalışması'), findsOneWidget);
    expect(find.text('Henüz gelen bildirim yok'), findsOneWidget);

    // Test bildirimi gönder butonuna tıkla
    await tester.tap(find.text('Test Bildirimi'));
    await tester.pumpAndSettle();

    expect(find.text('Softito Test Bildirimi #1'), findsOneWidget);
    expect(find.text('1 yeni'), findsOneWidget);

    // Bildirime tıklayarak detay diyaloğunu aç ve okundu işaretle
    await tester.tap(find.text('Softito Test Bildirimi #1'));
    await tester.pumpAndSettle();

    expect(find.text('Tamam'), findsOneWidget);
    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    // Okundu işaretlendiği için '1 yeni' rozeti kalkmalı
    expect(find.text('1 yeni'), findsNothing);

    // Tümünü temizle butonuna tıkla
    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Henüz gelen bildirim yok'), findsOneWidget);
  });
}
