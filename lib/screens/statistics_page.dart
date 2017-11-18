import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/redux_core.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/widgets/progress_chart.dart';

class _StatisticsPageViewModel {
  final double totalProgress;
  final double currentWeight;
  final double last7daysProgress;
  final double last30daysProgress;
  final List<WeightEntry> entries;

  _StatisticsPageViewModel({this.last7daysProgress,
    this.last30daysProgress,
    this.totalProgress,
    this.currentWeight,
    this.entries});
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _StatisticsPageViewModel>(
      converter: (store) {
        List<WeightEntry> entries = new List.from(store.state.entries);
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
          entries: store.state.entries,
        );
      },
      builder: (context, viewModel) {
        return new ListView(
          children: <Widget>[
            new _StatisticCardWrapper(
              child: new Padding(padding: new EdgeInsets.all(8.0),
                  child: new ProgressChart(viewModel.entries)),
              height: 200.0,
            ),
            new _StatisticCard(
              title: "Current weight",
              value: viewModel.currentWeight,
            ),
            new _StatisticCard(
              title: "Progress done",
              value: viewModel.totalProgress,
              processNumberSymbol: true,
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
                  ),
                ),
                new Expanded(
                  child: new _StatisticCard(
                    title: "Last month",
                    value: viewModel.last30daysProgress,
                    textSizeFactor: 0.8,
                    processNumberSymbol: true,
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

  _StatisticCard({this.title,
    this.value,
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
                    child: new Text("kg")),
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
