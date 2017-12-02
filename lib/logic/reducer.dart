import 'package:firebase_database/firebase_database.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

ReduxState reduce(ReduxState state, action) {
  ReduxState newState = state;
  if (action is InitAction) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  } else if (action is UserLoadedAction) {
    newState = state.copyWith(firebaseUser: action.firebaseUser);
  } else if (action is AddDatabaseReferenceAction) {
    newState = state.copyWith(mainReference: action.databaseReference);
  } else if (action is OnAddedAction) {
    newState = _onEntryAdded(state, action.event);
  } else if (action is OnChangedAction) {
    newState = _onEntryEdited(state, action.event);
  } else if (action is OnRemovedAction) {
    newState = _onEntryRemoved(state, action.event);
  } else if (action is AcceptEntryAddedAction) {
    newState = state.copyWith(hasEntryBeenAdded: false);
  } else if (action is AcceptEntryRemovalAction) {
    newState = state.copyWith(hasEntryBeenRemoved: false);
  } else if (action is OnUnitChangedAction) {
    newState = state.copyWith(unit: action.unit);
  }
  return newState;
}

ReduxState _onEntryAdded(ReduxState state, Event event) {
  List<WeightEntry> entries = []
    ..addAll(state.entries)
    ..add(new WeightEntry.fromSnapshot(event.snapshot))
    ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  return state.copyWith(
    hasEntryBeenAdded: true,
    entries: entries,
  );
}

ReduxState _onEntryEdited(ReduxState state, Event event) {
  var oldValue =
      state.entries.singleWhere((entry) => entry.key == event.snapshot.key);
  List<WeightEntry> entries = <WeightEntry>[]
    ..addAll(state.entries)
    ..[state.entries.indexOf(oldValue)] =
        new WeightEntry.fromSnapshot(event.snapshot)
    ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  return state.copyWith(
    entries: entries,
  );
}

ReduxState _onEntryRemoved(ReduxState state, Event event) {
  WeightEntry removedEntry =
      state.entries.singleWhere((entry) => entry.key == event.snapshot.key);
  List<WeightEntry> entries = <WeightEntry>[]
    ..addAll(state.entries)
    ..remove(removedEntry)
    ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime));
  return state.copyWith(
    entries: entries,
    lastRemovedEntry: removedEntry,
    hasEntryBeenRemoved: true,
  );
}
