import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

middleware(Store<ReduxState> store, action, NextDispatcher next) {
  print(action.runtimeType);
  if (action is InitAction) {
    _handleInitAction(store);
  } else if (action is AddEntryAction) {
    _handleAddEntryAction(store, action);
  } else if (action is EditEntryAction) {
    _handleEditEntryAction(store, action);
  } else if (action is RemoveEntryAction) {
    _handleRemoveEntryAction(store, action);
  } else if (action is UndoRemovalAction) {
    _handleUndoRemovalAction(store);
  } else if (action is SetUnitAction) {
    _handleSetUnitAction(action, store);
  }
  next(action);
  if (action is UserLoadedAction) {
    _handleUserLoadedAction(store);
  }
}
_handleUserLoadedAction(Store<ReduxState> store) {
  store.dispatch(new AddDatabaseReferenceAction(FirebaseDatabase.instance
      .reference()
      .child(store.state.firebaseState.firebaseUser.uid)
      .child("entries")
        ..onChildAdded
            .listen((event) => store.dispatch(new OnAddedAction(event)))
        ..onChildChanged
            .listen((event) => store.dispatch(new OnChangedAction(event)))
        ..onChildRemoved
            .listen((event) => store.dispatch(new OnRemovedAction(event)))));
}

_handleSetUnitAction(SetUnitAction action, Store<ReduxState> store) {
  _setUnit(action.unit)
      .then((nil) => store.dispatch(new OnUnitChangedAction(action.unit)));
}

_handleUndoRemovalAction(Store<ReduxState> store) {
  WeightEntry lastRemovedEntry = store.state.removedEntryState.lastRemovedEntry;
  store.state.firebaseState.mainReference
      .child(lastRemovedEntry.key)
      .set(lastRemovedEntry.toJson());
}

_handleRemoveEntryAction(Store<ReduxState> store, RemoveEntryAction action) {
  store.state.firebaseState.mainReference.child(action.weightEntry.key)
      .remove();
}

_handleEditEntryAction(Store<ReduxState> store, EditEntryAction action) {
  store.state.firebaseState.mainReference
      .child(action.weightEntry.key)
      .set(action.weightEntry.toJson());
}

_handleAddEntryAction(Store<ReduxState> store, AddEntryAction action) {
  store.state.firebaseState.mainReference.push().set(
      action.weightEntry.toJson());
}

_handleInitAction(Store<ReduxState> store) {
  _loadUnit().then((unit) => store.dispatch(new OnUnitChangedAction(unit)));
  if (store.state.firebaseState.firebaseUser == null) {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        store.dispatch(new UserLoadedAction(user));
      } else {
        FirebaseAuth.instance
            .signInAnonymously()
            .then((user) => store.dispatch(new UserLoadedAction(user)));
      }
    });
  }
}

Future _setUnit(String unit) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('unit', unit);
}

Future<String> _loadUnit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('unit') ?? 'kg';
}
