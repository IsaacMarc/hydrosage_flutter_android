import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosage_app/main.dart';

void main() {
  testWidgets('HydroSageApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HydroSageApp());
    expect(find.byType(HydroSageApp), findsOneWidget);
  });
}
