import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';

void main() {
  WeightEntry activeEntry = new WeightEntry(new DateTime.now(), 70.0, null);
  ReduxState defaultState = new ReduxState(
      unit: 'kg', entries: [], isEditMode: true, activeEntry: activeEntry);

  pumpSettingWidget(Store store, WidgetTester tester) async {
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new StoreProvider(
        store: store,
        child: new MaterialApp(home: new WeightEntryDialog()),
      );
    }));
  }

  testWidgets('WeightEntryDialog has "Edit entry" in header',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(AppBar, 'Edit entry'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "New entry" in header',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce,
            initialState: defaultState.copyWith(isEditMode: false)),
        tester);
    expect(find.widgetWithText(AppBar, 'New entry'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "SAVE" button when edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(FlatButton, 'SAVE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "SAVE" button when not edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce,
            initialState: defaultState.copyWith(isEditMode: false)),
        tester);
    expect(find.widgetWithText(FlatButton, 'SAVE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "DELETE" button when edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(FlatButton, 'DELETE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has not "DELETE" button when not edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce,
            initialState: defaultState.copyWith(isEditMode: false)),
        tester);
    expect(find.widgetWithText(FlatButton, 'DELETE'), findsNothing);
  });

  testWidgets('WeightEntryDialog displays weight in kg',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState), tester);
    expect(find.text('70.0 kg'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog displays weight in lbs',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState.copyWith(unit: 'lbs')),
        tester);
    expect(find.text('154.0 lbs'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog displays hint when note is null',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store(reduce, initialState: defaultState), tester);
    expect(find.text('Optional note'), findsOneWidget);
  });

  //DatePickerDialog is private
  testWidgets('WeightEntryDialog opens MonthPicker on date click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store(reduce, initialState: defaultState), tester);
        await tester.tap(find.byKey(new Key('CalendarItem')));
        await tester.pump();
        expect(find.byType(MonthPicker), findsOneWidget);
      });

  //TimePicker is private
  testWidgets('WeightEntryDialog opens Dialog on time click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store(reduce, initialState: defaultState), tester);
        await tester.tap(find.byKey(new Key('TimeItem')));
        await tester.pump();
        expect(find.byType(Dialog), findsOneWidget);
      });

  testWidgets('WeightEntryDialog opens NumberPickerDialog on weight click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store(reduce, initialState: defaultState), tester);
        await tester.tap(find.text('70.0 kg'));
        await tester.pump();
        expect(find.byType(NumberPickerDialog), findsOneWidget);
        expect(find.text('70'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });
}
