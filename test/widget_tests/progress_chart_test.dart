import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart' as rdx;
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/widgets/progress_chart.dart';

void main() {
  testWidgets("test", (WidgetTester tester) async {
    //given
    WeightEntry entry = new WeightEntry(new DateTime.now(), 70.0, null);
    Store<rdx.ReduxState> store = new Store<rdx.ReduxState>(
      reduce,
      initialState: new rdx.ReduxState(
        entries: [entry],
        progressChartState: new rdx.ProgressChartState(daysToShow: 31),
      ),
    );
    await tester.pumpWidget(new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return new StoreProvider(
        store: store,
        child: new ProgressChart(),
      );
    }));
    //when
    //TODO: Test gesture zoomin
    //then
    //expect(store.state.progressChartState.daysToShow, lessThan(31));
  });
}
