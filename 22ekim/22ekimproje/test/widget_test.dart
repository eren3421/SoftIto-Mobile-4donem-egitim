import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentor_app/main.dart';

void main() {
  testWidgets('MentorApp builds and shows auth screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MentorApp(),
      ),
    );

    // MENTOR başlığını ve Giriş Yap yazısını doğrula
    expect(find.text('MENTOR'), findsWidgets);
    expect(find.text('Giriş Yap'), findsWidgets);
  });
}
