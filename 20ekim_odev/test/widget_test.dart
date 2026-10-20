import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_rental/app.dart';
import 'package:multimodal_rental/features/tracking/controllers/tracking_controller.dart';

void main() {
  testWidgets('MultiModalRentalApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MultiModalRentalApp());
    expect(find.text('Çok Modlu Araç Kiralama'), findsWidgets);
    TrackingController.instance.stopSimulation();
  });
}
