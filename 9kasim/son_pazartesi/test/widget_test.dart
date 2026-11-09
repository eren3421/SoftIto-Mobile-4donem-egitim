import 'package:flutter_test/flutter_test.dart';
import 'package:son_pazartesi/main.dart';

void main() {
  testWidgets('MiniCuzdan smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniCuzdan());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Kodvance BLoC Cüzdan'), findsOneWidget);
  });
}

