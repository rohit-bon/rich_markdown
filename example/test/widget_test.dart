import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('DemoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Rich Markdown Playground'), findsOneWidget);
    expect(find.text('Content type'), findsOneWidget);
  });
}
