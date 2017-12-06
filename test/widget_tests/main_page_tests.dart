import 'package:flutter_test/flutter_test.dart';
import 'package:weight_tracker/main.dart';

void main() {
  testWidgets('my first widget test', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.text('Weight Tracker'), findsOneWidget);
  });
}
