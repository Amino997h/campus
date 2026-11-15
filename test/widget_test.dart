import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/main.dart' as app;

void main() {
  testWidgets('Test first page loads', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  });
}