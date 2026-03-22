import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/app.dart';

void main() {
  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const NeuroInjectApp());
    expect(find.text('Injection Guide'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
  });
}
