import 'package:flutter_test/flutter_test.dart';
import 'package:weight_tracker/main.dart';

void main() {
  testWidgets('App name in header', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.text('Weight Tracker'), findsOneWidget);
  });
}
