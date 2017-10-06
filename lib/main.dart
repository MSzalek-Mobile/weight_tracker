import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/home_page.dart';
import 'package:weight_tracker/logic/redux_core.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final Store store = new Store(stateReducer, initialState: new ReduxState());

  @override
  Widget build(BuildContext context) {
    store.dispatch(new InitAction(
      onEntryAddedCallback: (event) => store.dispatch(new OnAddedAction(event)),
      onEntryEditedCallback: (event) =>
          store.dispatch(new OnChangedAction(event)),
    ));
    return new MaterialApp(
      title: 'Weight Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new StoreProvider(
        store: store,
        child: new HomePage(title: 'Weight Tracker'),
      ),
    );
  }
}
