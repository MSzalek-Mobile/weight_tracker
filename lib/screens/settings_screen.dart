import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';

@immutable
class SettingsPageViewModel {
  final String unit;
  final Function(String) onUnitChanged;

  SettingsPageViewModel({this.unit, this.onUnitChanged});
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, SettingsPageViewModel>(
        converter: (store) {
      return new SettingsPageViewModel(
        unit: store.state.unit,
        onUnitChanged: (newUnit) => store.dispatch(new SetUnitAction(newUnit)),
      );
    }, builder: (context, viewModel) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Settings"),
        ),
        body: Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(16.0),
              child: _unitView(context, viewModel),
            ),
//            ProfileView(),
          ],
        ),
      );
    });
  }

  Row _unitView(BuildContext context, SettingsPageViewModel viewModel) {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: new Text(
          "Unit",
          style: Theme.of(context).textTheme.headline,
        )),
        new DropdownButton<String>(
          key: const Key('UnitDropdown'),
          value: viewModel.unit,
          items: <String>["kg", "lbs"].map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (newUnit) => viewModel.onUnitChanged(newUnit),
        ),
      ],
    );
  }
}
