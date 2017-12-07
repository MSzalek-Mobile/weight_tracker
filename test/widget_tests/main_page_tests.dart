import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_tracker/main.dart';
import 'package:weight_tracker/screens/statistics_page.dart';

void main() {
  testWidgets('App name in header', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.widgetWithText(AppBar, 'Weight Tracker'), findsOneWidget);
  });

  testWidgets('Main screen has two tabs', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.byType(Tab), findsNWidgets(2));
  });

  testWidgets(
      'Main screen has statistics tab in bar', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(
        find.byWidgetPredicate((widget) =>
        widget is Tab &&
            widget.key == new Key('StatisticsTab') &&
            widget.text == 'STATISTICS' &&
            (widget.icon as Icon).icon == Icons.show_chart),
        findsOneWidget);
  });

  testWidgets('Main screen has statistics tab in tabview ', (
      WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.byType(StatisticsPage), findsOneWidget);
  });

  testWidgets(
      'Main screen has history tab in bar', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());
    expect(
        find.byWidgetPredicate((widget) =>
        widget is Tab &&
            widget.key == new Key('HistoryTab') &&
            widget.text == 'HISTORY' &&
            (widget.icon as Icon).icon == Icons.history),
        findsOneWidget);
  });
}
