import 'package:flutter_test/flutter_test.dart';
import 'package:counter_app/main.dart';

void main() {
  testWidgets('Counter app smoke test: +1 and +5 buttons test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CounterApp());

    // Verify initial count is 0
    expect(find.text('0'), findsOneWidget);

    // Tap '+1 Ekle'
    await tester.tap(find.text('+1 Ekle'));
    await tester.pump();

    // Verify counter increased to 1
    expect(find.text('1'), findsOneWidget);

    // Tap '+5 Ekle'
    await tester.tap(find.text('+5 Ekle'));
    await tester.pump();

    // Verify counter increased to 6
    expect(find.text('6'), findsOneWidget);
  });
}
