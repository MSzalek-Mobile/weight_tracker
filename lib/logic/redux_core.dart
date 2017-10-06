import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class LocalAddAction {
  final WeightEntry weightEntry;

  LocalAddAction(this.weightEntry);
}

class LocalEditAction {
  final WeightEntry weightEntry;

  LocalEditAction(this.weightEntry);
}

typedef void EventCallback(Event event);

class InitAction {
  final EventCallback onEntryAddedCallback;
  final EventCallback onEntryEditedCallback;

  InitAction({this.onEntryAddedCallback, this.onEntryEditedCallback});
}

class OnAddedAction {
  final Event event;

  OnAddedAction(this.event);
}

class OnChangedAction {
  final Event event;

  OnChangedAction(this.event);
}

class AcceptEntryAddedAction {}

class ReduxState {
  FirebaseUser firebaseUser;
  DatabaseReference mainReference;
  List<WeightEntry> entries = new List();
  bool hasEntryBeenAdded = false;
}

ReduxState stateReducer(ReduxState state, action) {
  if (action is InitAction) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _loginAnonymous(state).then((nil) => _updateFirebaseAuth(state, action));
  } else if (action is LocalAddAction) {
    _addEntry(state, action.weightEntry);
  } else if (action is LocalEditAction) {
    _editEntry(state, action.weightEntry);
  } else if (action is OnAddedAction) {
    _onEntryAdded(state, action.event);
  } else if (action is OnChangedAction) {
    _onEntryEdited(state, action.event);
  } else if (action is AcceptEntryAddedAction) {
    state.hasEntryBeenAdded = false;
  }
  return state;
}

Future<Null> _loginAnonymous(ReduxState state) async {
  if (state.firebaseUser == null) {
    state.firebaseUser = await FirebaseAuth.instance.currentUser();
  }
  if (state.firebaseUser == null) {
    state.firebaseUser = await FirebaseAuth.instance.signInAnonymously();
  }
}

_updateFirebaseAuth(ReduxState state, InitAction action) async {
  state.mainReference = FirebaseDatabase.instance
      .reference()
      .child(state.firebaseUser.uid)
      .child("entries");
  state.mainReference.onChildAdded.listen(action.onEntryAddedCallback);
  state.mainReference.onChildChanged.listen(action.onEntryEditedCallback);
}

_addEntry(ReduxState state, WeightEntry entry) {
  state.mainReference.push().set(entry.toJson());
}

_editEntry(ReduxState state, WeightEntry entry) {
  state.mainReference.child(entry.key).set(entry.toJson());
}

_onEntryAdded(ReduxState state, Event event) {
  state.entries.add(new WeightEntry.fromSnapshot(event.snapshot));
  state.entries.sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  state.hasEntryBeenAdded = true;
}

_onEntryEdited(ReduxState state, Event event) {
  var oldValue =
      state.entries.singleWhere((entry) => entry.key == event.snapshot.key);
  state.entries[state.entries.indexOf(oldValue)] =
      new WeightEntry.fromSnapshot(event.snapshot);
  state.entries.sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
}
