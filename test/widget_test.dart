import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosage_app/main.dart';

void main() {
  testWidgets('LeafifyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LeafifyApp());
    expect(find.byType(LeafifyApp), findsOneWidget);
  });
}
