import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/middleware.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/screens/settings_screen.dart';

void main() {
  final Store<ReduxState> store = new Store<ReduxState>(reduce,
      initialState: new ReduxState(),
      middleware: [middleware].toList());

  pumpSettingWidget(WidgetTester tester) async {
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new StoreProvider<ReduxState>(
        store: store,
        child: new MaterialApp(home: new SettingsPage()),
      );
    }));
  }

  testWidgets('SettingsPage has "Settings" in header',
      (WidgetTester tester) async {
    await pumpSettingWidget(tester);
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
  });

  testWidgets('SettingsPage has Unit label', (WidgetTester tester) async {
    await pumpSettingWidget(tester);
    expect(find.text('Unit'), findsOneWidget);
  });

  testWidgets('Settings has spinner with kg and lbs',
      (WidgetTester tester) async {
    await pumpSettingWidget(tester);
    expect(find.byKey(const Key('UnitDropdown')), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);
  });
}
