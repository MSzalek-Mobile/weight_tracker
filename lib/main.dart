import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_core.dart';
import 'package:weight_tracker/screens/main_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final Store store = new Store(stateReducer,
      initialState: new ReduxState(
          firebaseUser: null,
          mainReference: null,
          entries: new List(),
          hasEntryBeenAdded: false,
          lastRemovedEntry: null,
          hasEntryBeenRemoved: false),
      middleware: [firebaseMiddleware].toList());

  @override
  Widget build(BuildContext context) {
    store.dispatch(new InitAction());
    return new MaterialApp(
      title: 'Weight Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new StoreProvider(
        store: store,
        child: new MainPage(title: "Weight Tracker"),
      ),
    );
  }
}
