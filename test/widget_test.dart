import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_driver_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxiDriverApp());
    expect(find.byType(TaxiDriverApp), findsOneWidget);
  });
}
