import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_tracker/widgets/progress_chart_dropdown.dart';

void main() {
  testWidgets('If 10 days tpo show, then 10 days label is displayed',
      (WidgetTester tester) async {
    await _pumpDropdown(tester, daysToShow: 10);
    expect(find.text("10 days"), findsOneWidget);
  });

  testWidgets('If 31 days tpo show, then 1 month label is displayed',
      (WidgetTester tester) async {
    await _pumpDropdown(tester, daysToShow: 31);
    expect(find.text("month"), findsOneWidget);
  });
}

_pumpDropdown(WidgetTester tester,
    {int daysToShow, Function(DateTime) onStartSelected}) async {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProgressChartDropdown(
          daysToShow: daysToShow,
          onStartSelected: onStartSelected,
        ),
      ),
    ),
  );
}
