import 'package:flutter_test/flutter_test.dart';
import 'package:asistan/core/theme/theme_controller.dart';
import 'package:asistan/main.dart';

void main() {
  testWidgets('AsistanApp smoke test', (WidgetTester tester) async {
    final themeController = ThemeController();
    await tester.pumpWidget(AsistanApp(themeController: themeController));

    expect(find.text('Asistan'), findsOneWidget);
    expect(find.text('Finans & Kaynak Tablosu'), findsOneWidget);

    themeController.dispose();
  });
}
