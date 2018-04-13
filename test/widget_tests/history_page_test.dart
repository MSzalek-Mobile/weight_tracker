import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/history_page.dart';
import 'package:weight_tracker/widgets/weight_list_item.dart';

void main() {
  WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
  ReduxState defaultState = new ReduxState(unit: 'kg', entries: [entry, entry]);

  pumpSettingWidget(Store<ReduxState> store, WidgetTester tester) async {
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new StoreProvider<ReduxState>(
        store: store,
        child: new MaterialApp(home: new Scaffold(body: new HistoryPage())),
      );
    }));
  }

  testWidgets('HistoryPage has text if there are no entries',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(
            reduce, initialState: defaultState.copyWith(entries: [])),
        tester);
    expect(find.text('Add your weight to see history'), findsOneWidget);
  });

  testWidgets('HistoryPage has ListView', (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('HistoryPage has 2 items for 2 entries',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.byType(WeightListItem), findsNWidgets(2));
  });

  testWidgets('HistoryPage shows snackbar if entry was removed',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(
          reduce,
          initialState: defaultState.copyWith(
            removedEntryState: defaultState.removedEntryState
                .copyWith(hasEntryBeenRemoved: true),
          ),
        ),
        tester);
    await tester.pump(new Duration(milliseconds: 100));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('HistoryPage shows snackbar with proper text',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(
          reduce,
          initialState: defaultState.copyWith(
            removedEntryState: defaultState.removedEntryState
                .copyWith(hasEntryBeenRemoved: true),
          ),
        ),
        tester);
    await tester.pump(new Duration(milliseconds: 100));
    expect(find.text('Entry deleted.'), findsOneWidget);
  });

  testWidgets('HistoryPage shows snackbar with proper action',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(
          reduce,
          initialState: defaultState.copyWith(
            removedEntryState: defaultState.removedEntryState
                .copyWith(hasEntryBeenRemoved: true),
          ),
        ),
        tester);
    await tester.pump(new Duration(milliseconds: 100));
    expect(find.widgetWithText(SnackBarAction, 'UNDO'), findsOneWidget);
  });
}
