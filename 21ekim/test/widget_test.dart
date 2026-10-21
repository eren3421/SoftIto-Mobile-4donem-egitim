import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:bahcivan/state/app_state.dart';
import 'package:bahcivan/screens/auth_screen.dart';
import 'package:bahcivan/screens/calendar_logs_screen.dart';
import 'package:bahcivan/screens/greenhouse_detail_screen.dart';
import 'package:bahcivan/screens/plant_detail_screen.dart';
import 'package:flutter/material.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Auth screen renders brand title and inputs',
      (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BAHÇIVAN'), findsOneWidget);
    expect(find.text('Kullanıcı Giriş'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });

  testWidgets('CalendarLogsScreen has 3 tabs and renders Notes tab with filter chips',
      (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: CalendarLogsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Tab headers
    expect(find.text('Bakım Takvimi'), findsOneWidget);
    expect(find.text('Hasat ve Verim Günlüğü'), findsOneWidget);
    expect(find.text('Notlar & Günlük'), findsOneWidget);

    // Switch to Tab 3 (Notlar & Günlük)
    await tester.tap(find.text('Notlar & Günlük'));
    await tester.pumpAndSettle();

    // Verify filter chips
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.textContaining('Genel Notlar'), findsOneWidget);
    expect(find.textContaining('Tedavi'), findsOneWidget);

    // Verify presence of seed notes
    expect(find.textContaining('Sera Havalandırma Notu'), findsOneWidget);
  });

  testWidgets('GreenhouseDetailScreen shows notes tab and notes list',
      (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: GreenhouseDetailScreen(greenhouseId: 'gh_01'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify tab headers
    expect(find.textContaining('Sera Notları'), findsOneWidget);

    // Tap on Sera Notları tab
    await tester.tap(find.textContaining('Sera Notları'));
    await tester.pumpAndSettle();

    // Notes list or add note button should be visible
    expect(find.textContaining('Sera Havalandırma Notu'), findsOneWidget);
  });

  testWidgets('PlantDetailScreen shows Section 5 Bitki Notları ve Günlük',
      (WidgetTester tester) async {
    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: PlantDetailScreen(plantId: 'plt_101'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Section 5 is present
    expect(find.text('5. BİTKİ NOTLARI VE GÜNLÜK'), findsOneWidget);
    expect(find.textContaining('İlk Salkım Hasadı'), findsOneWidget);
  });
}
