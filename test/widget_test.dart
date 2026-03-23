import 'package:flutter_test/flutter_test.dart';
import 'package:gaesde_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GaesdeApp());
    expect(find.text('Usuários'), findsOneWidget);
  });
}
