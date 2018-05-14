import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/constants.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';
import 'package:weight_tracker/widgets/progress_chart.dart';

class _StatisticsPageViewModel {
  final double totalProgress;
  final double currentWeight;
  final double last7daysProgress;
  final double last30daysProgress;
  final List<WeightEntry> entries;
  final String unit;
  final Function() openAddEntryDialog;

  _StatisticsPageViewModel({
    this.last7daysProgress,
    this.last30daysProgress,
    this.totalProgress,
    this.currentWeight,
    this.entries,
    this.unit,
    this.openAddEntryDialog,
  });
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _StatisticsPageViewModel>(
      converter: (store) {
        String unit = store.state.unit;
        List<WeightEntry> entries = new List();
        store.state.entries.forEach((entry) {
          if (unit == "kg") {
            entries.add(entry);
          } else {
            entries.add(entry.copyWith(weight: entry.weight * KG_LBS_RATIO));
          }
        });
        List<WeightEntry> last7daysEntries = entries
            .where((entry) =>
            entry.dateTime
                .isAfter(new DateTime.now().subtract(new Duration(days: 7))))
            .toList();
        List<WeightEntry> last30daysEntries = entries
            .where((entry) =>
            entry.dateTime
                .isAfter(new DateTime.now().subtract(new Duration(days: 30))))
            .toList();
        return new _StatisticsPageViewModel(
          totalProgress: entries.isEmpty
              ? 0.0
              : (entries.first.weight - entries.last.weight),
          currentWeight: entries.isEmpty ? 0.0 : entries.first.weight,
          last7daysProgress: last7daysEntries.isEmpty
              ? 0.0
              : (last7daysEntries.first.weight - last7daysEntries.last.weight),
          last30daysProgress: last30daysEntries.isEmpty
              ? 0.0
              : (last30daysEntries.first.weight -
              last30daysEntries.last.weight),
          entries: entries,
          unit: unit,
          openAddEntryDialog: () {
            if (last30daysEntries.isEmpty) {
              store.dispatch(new OpenAddEntryDialog());
              Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) {
                  return new WeightEntryDialog();
                },
                fullscreenDialog: true,
              ));
            }
          },
        );
      },
      builder: (context, viewModel) {
        return new ListView(
          children: <Widget>[
            new GestureDetector(
              onTap: viewModel.openAddEntryDialog,
              child: new _StatisticCardWrapper(
                child: new Padding(
                    padding: new EdgeInsets.all(8.0),
                    child: new ProgressChart()),
                height: 250.0,
              ),
            ),
            new _StatisticCard(
              title: "Current weight",
              value: viewModel.currentWeight,
              unit: viewModel.unit,
            ),
            new _StatisticCard(
              title: "Progress done",
              value: viewModel.totalProgress,
              processNumberSymbol: true,
              unit: viewModel.unit,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Expanded(
                  child: new _StatisticCard(
                    title: "Last week",
                    value: viewModel.last7daysProgress,
                    textSizeFactor: 0.8,
                    processNumberSymbol: true,
                    unit: viewModel.unit,
                  ),
                ),
                new Expanded(
                  child: new _StatisticCard(
                    title: "Last month",
                    value: viewModel.last30daysProgress,
                    textSizeFactor: 0.8,
                    processNumberSymbol: true,
                    unit: viewModel.unit,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class _StatisticCardWrapper extends StatelessWidget {
  final double height;
  final Widget child;

  _StatisticCardWrapper({this.height = 120.0, this.child});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        new Expanded(
          child: new Container(
            height: height,
            child: new Card(child: child),
          ),
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final num value;
  final bool processNumberSymbol;
  final double textSizeFactor;
  final String unit;

  _StatisticCard({this.title,
    this.value,
    this.unit,
    this.processNumberSymbol = false,
    this.textSizeFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    Color numberColor =
        (processNumberSymbol && value > 0) ? Colors.red : Colors.green;
    String numberSymbol = processNumberSymbol && value > 0 ? "+" : "";
    return new _StatisticCardWrapper(
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new Row(
              children: [
                new Text(
                  numberSymbol + value.toStringAsFixed(1),
                  textScaleFactor: textSizeFactor,
                  style: Theme
                      .of(context)
                      .textTheme
                      .display2
                      .copyWith(color: numberColor),
                ),
                new Padding(
                    padding: new EdgeInsets.only(left: 5.0),
                    child: new Text(unit)),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          new Padding(
            child: new Text(title),
            padding: new EdgeInsets.only(bottom: 8.0),
          ),
        ],
      ),
    );
  }
}
