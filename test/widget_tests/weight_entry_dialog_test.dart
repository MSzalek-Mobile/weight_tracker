import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';
import 'package:matcher/matcher.dart' as matchers;

void main() {
  WeightEntry activeEntry = new WeightEntry(new DateTime.now(), 70.0, null);
  WeightEntryDialogReduxState dialogState = new WeightEntryDialogReduxState(
      isEditMode: true, activeEntry: activeEntry);
  WeightEntryDialogReduxState dialogAddState =
  dialogState.copyWith(isEditMode: false);
  ReduxState defaultState = new ReduxState(weightEntryDialogState: dialogState);

  pumpSettingWidget(Store<ReduxState> store, WidgetTester tester) async {
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new StoreProvider<ReduxState>(
        store: store,
        child: new MaterialApp(home: new WeightEntryDialog()),
      );
    }));
  }

  testWidgets('WeightEntryDialog has "Edit entry" in header',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(AppBar, 'Edit entry'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "New entry" in header',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce,
            initialState:
            defaultState.copyWith(weightEntryDialogState: dialogAddState)),
        tester);
    expect(find.widgetWithText(AppBar, 'New entry'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "SAVE" button when edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(FlatButton, 'SAVE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "SAVE" button when not edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce,
            initialState:
            defaultState.copyWith(weightEntryDialogState: dialogAddState)),
        tester);
    expect(find.widgetWithText(FlatButton, 'SAVE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has "DELETE" button when edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.widgetWithText(FlatButton, 'DELETE'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog has not "DELETE" button when not edit',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce,
            initialState:
            defaultState.copyWith(weightEntryDialogState: dialogAddState)),
        tester);
    expect(find.widgetWithText(FlatButton, 'DELETE'), findsNothing);
  });

  testWidgets('WeightEntryDialog displays weight in kg',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.text('70.0 kg'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog displays weight in lbs',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(
            reduce, initialState: defaultState.copyWith(unit: 'lbs')),
        tester);
    expect(find.text('154.0 lbs'), findsOneWidget);
  });

  testWidgets('WeightEntryDialog displays hint when note is null',
      (WidgetTester tester) async {
    await pumpSettingWidget(
        new Store<ReduxState>(reduce, initialState: defaultState), tester);
    expect(find.text('Optional note'), findsOneWidget);
  });

  //DatePickerDialog is private
  testWidgets('WeightEntryDialog opens MonthPicker on date click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store<ReduxState>(reduce, initialState: defaultState), tester);
        await tester.tap(find.byKey(new Key('CalendarItem')));
        await tester.pump();
        expect(find.byType(MonthPicker), findsOneWidget);
      });

  //TimePicker is private
  testWidgets('WeightEntryDialog opens Dialog on time click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store<ReduxState>(reduce, initialState: defaultState), tester);
        await tester.tap(find.byKey(new Key('TimeItem')));
        await tester.pump();
        expect(find.byType(Dialog), findsOneWidget);
      });

  testWidgets('WeightEntryDialog opens NumberPickerDialog on weight click',
          (WidgetTester tester) async {
        await pumpSettingWidget(
            new Store<ReduxState>(reduce, initialState: defaultState), tester);
        await tester.tap(find.text('70.0 kg'));
        await tester.pump();
        expect(find.byType(NumberPickerDialog), findsOneWidget);
        expect(find.text('70'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });

  testWidgets('Clicking Save on edit invokes EditEntryAction with activeEntry',
          (WidgetTester tester) async {
        WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
        var reducer = (state, action) {
          expect(action, matchers.TypeMatcher<EditEntryAction>());
          expect((action as EditEntryAction).weightEntry, entry);
        };
        await pumpSettingWidget(
            new Store(
              reducer,
              initialState: defaultState.copyWith(
                weightEntryDialogState: dialogState.copyWith(
                    activeEntry: entry),
              ),
            ),
            tester);
        await tester.tap(find.text('SAVE'));
      });

  testWidgets('Clicking Save on create invokes AddEntryAction with ActiveEntry',
          (WidgetTester tester) async {
        WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
        var reducer = (state, action) {
          expect(action, matchers.TypeMatcher<AddEntryAction>());
          expect((action as AddEntryAction).weightEntry, entry);
        };
        await pumpSettingWidget(
            new Store(
              reducer,
              initialState: defaultState.copyWith(
                weightEntryDialogState: dialogAddState.copyWith(
                    activeEntry: entry),
              ),
            ),
            tester);
        await tester.tap(find.text('SAVE'));
      });

  testWidgets('Clicking Delete invokes RemoveEntryAction with activeEntry',
          (WidgetTester tester) async {
        WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
        var reducer = (state, action) {
          expect(action, matchers.TypeMatcher<RemoveEntryAction>());
          expect((action as RemoveEntryAction).weightEntry, entry);
        };
        await pumpSettingWidget(
            new Store(
              reducer,
              initialState: defaultState.copyWith(
                weightEntryDialogState: dialogState.copyWith(
                    activeEntry: entry),
              ),
            ),
            tester);
        await tester.tap(find.text('DELETE'));
      });

  testWidgets('Changing note updates activeEntry', (WidgetTester tester) async {
    WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
    Store<ReduxState> store = new Store(reduce,
        initialState: defaultState.copyWith(
          weightEntryDialogState: dialogState.copyWith(activeEntry: entry),
        ));
    await pumpSettingWidget(store, tester);
    await tester.enterText(find.byType(TextField), 'Lorem');
    expect(store.state.weightEntryDialogState.activeEntry.note, 'Lorem');
  });
}
