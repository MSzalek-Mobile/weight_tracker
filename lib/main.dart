import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/middleware.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/screens/main_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = new FirebaseAnalytics();
  final Store<ReduxState> store = new Store<ReduxState>(reduce,
      initialState: new ReduxState(
          entries: [],
          unit: 'kg',
          removedEntryState: new RemovedEntryState(hasEntryBeenRemoved: false),
          firebaseState: new FirebaseState(),
          mainPageState: new MainPageReduxState(hasEntryBeenAdded: false),
          weightEntryDialogState: new WeightEntryDialogReduxState()),
      middleware: [middleware].toList());

  @override
  Widget build(BuildContext context) {
    store.dispatch(new InitAction());
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'Weight Tracker',
        theme: new ThemeData(
          primarySwatch: Colors.green,
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: new MainPage(title: "Weight Tracker", analytics: analytics),
      ),
    );
  }
}
