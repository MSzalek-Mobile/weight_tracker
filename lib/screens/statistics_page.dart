import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/redux_core.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class _StatisticsPageViewModel {
  final double totalProgress;
  final double currentWeight;

  _StatisticsPageViewModel({this.totalProgress, this.currentWeight});
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _StatisticsPageViewModel>(
      converter: (store) {
        List<WeightEntry> entries = store.state.entries;
        return new _StatisticsPageViewModel(
          totalProgress: entries.isEmpty
              ? 0.0
              : (entries.first.weight - entries.last.weight),
          currentWeight: entries.isEmpty ? 0.0 : entries.first.weight,
        );
      },
      builder: (context, viewModel) {
        return new ListView(
          children: <Widget>[
            new _StatisticCard(
              title: "Current weight",
              value: viewModel.currentWeight,
            ),
            new _StatisticCard(
              title: "Progress done",
              value: viewModel.totalProgress,
              processNumberSymbol: true,
            ),
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

  _StatisticCard({this.title, this.value, this.processNumberSymbol = false});

  @override
  Widget build(BuildContext context) {
    Color numberColor =
        (processNumberSymbol && value > 0) ? Colors.red : Colors.green;
    String numberSymbol = processNumberSymbol ? (value < 0 ? "-" : "+") : "";
    return new _StatisticCardWrapper(
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new Row(
              children: [
                new Text(
                  numberSymbol + value.toString(),
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
