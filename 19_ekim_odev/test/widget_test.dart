import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defterim/core/theme/theme_controller.dart';
import 'package:defterim/features/diary/controllers/diary_controller.dart';
import 'package:defterim/main.dart';

void main() {
  testWidgets(
      'Defterim ana ekran, tema, takvim, favori filtresi ve sayfa yazma testi',
      (WidgetTester tester) async {
    final themeController = ThemeController();
    final diaryController = DiaryController();

    await tester.pumpWidget(
      DefterimApp(
        themeController: themeController,
        diaryController: diaryController,
      ),
    );
    await tester.pumpAndSettle();

    // Başlık ve demo sayfaların ekranda olduğunu doğrula
    expect(find.text('Defterim'), findsOneWidget);
    expect(find.text('Defterime İlk Satırlar'), findsOneWidget);
    expect(find.text('Gece Fikirleri ve İlham'), findsOneWidget);

    // Favoriler ve Takvim butonlarının varlığını doğrula
    expect(find.byTooltip('Sadece Favorileri Göster'), findsOneWidget);
    expect(find.byTooltip('Tarihe Göre Sayfaları Seç'), findsOneWidget);
    expect(find.text('Yeni Sayfa'), findsOneWidget);

    // Favori filtresi butonuna tıkla
    await tester.tap(find.byTooltip('Sadece Favorileri Göster'));
    await tester.pumpAndSettle();

    // Sadece favori olan ilk demo entry görünmeli, favori olmayan filtrelenmeli
    expect(find.text('Defterime İlk Satırlar'), findsOneWidget);
    expect(find.text('Gece Fikirleri ve İlham'), findsNothing);

    // Favori filtresini kaldır
    await tester.tap(find.byTooltip('Tüm Sayfaları Göster'));
    await tester.pumpAndSettle();
    expect(find.text('Gece Fikirleri ve İlham'), findsOneWidget);

    // Tema değiştirme butonuna basarak dark mode geçişini test et
    final themeToggleFinder = find.byTooltip('Koyu Gece Modu');
    expect(themeToggleFinder, findsOneWidget);
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();
    expect(themeController.isDarkMode, isTrue);

    // Takvim ile tarih filtrelemeyi test et
    final today = DateTime.now();
    diaryController.setFilterDate(today);
    await tester.pumpAndSettle();

    // Tarih filtresi çubuğunun ekranda olduğunu doğrula
    expect(find.textContaining('Tarih:'), findsOneWidget);

    // Filtreyi temizleme butonuna bas ve tüm sayfaların geri geldiğini gör
    await tester.tap(find.byTooltip('Filtreyi Kaldır'));
    await tester.pumpAndSettle();
    expect(find.text('Gece Fikirleri ve İlham'), findsOneWidget);

    // FAB butonuna tıklayarak yeni sayfa yazma ekranının açıldığını test et
    await tester.tap(find.text('Yeni Sayfa'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Defter Sayfası'), findsOneWidget);
    expect(find.text('Sayfa Başlığı...'), findsOneWidget);

    // Sayfa başlığı ve içerik yazma
    await tester.enterText(find.byType(TextField).first, 'Harika Bir Gün');
    await tester.enterText(
      find.byType(TextField).last,
      'Bugün her şey yolunda gitti.',
    );

    // Kaydet butonuna bas
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    // Ana ekrana dönüldüğünü ve yeni sayfanın eklendiğini doğrula
    expect(find.text('Harika Bir Gün'), findsOneWidget);

    // Temizleme
    diaryController.dispose();
    themeController.dispose();
  });
}
