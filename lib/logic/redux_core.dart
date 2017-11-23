import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/model/weight_entry.dart';

@immutable
class ReduxState {
  final FirebaseUser firebaseUser;
  final DatabaseReference mainReference;
  final List<WeightEntry> entries;
  final bool hasEntryBeenAdded; //in other words: should scroll to top?
  final WeightEntry lastRemovedEntry;
  final bool hasEntryBeenRemoved; //in other words: should show snackbar?

  ReduxState({this.firebaseUser,
    this.mainReference,
    this.entries,
    this.hasEntryBeenAdded,
    this.lastRemovedEntry,
    this.hasEntryBeenRemoved});

  ReduxState copyWith({FirebaseUser firebaseUser,
    DatabaseReference mainReference,
    List<WeightEntry> entries,
    bool hasEntryBeenAdded,
    WeightEntry lastRemovedEntry,
    bool hasEntryBeenRemoved}) {
    return new ReduxState(
        firebaseUser: firebaseUser ?? this.firebaseUser,
        mainReference: mainReference ?? this.mainReference,
        entries: entries ?? this.entries,
        hasEntryBeenAdded: hasEntryBeenAdded ?? this.hasEntryBeenAdded,
        lastRemovedEntry: lastRemovedEntry ?? this.lastRemovedEntry,
        hasEntryBeenRemoved: hasEntryBeenRemoved ?? this.hasEntryBeenRemoved);
  }
}

firebaseMiddleware(Store<ReduxState> store, action, NextDispatcher next) {
  print(action.runtimeType);
  if (action is InitAction) {
    if (store.state.firebaseUser == null) {
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
  } else if (action is AddEntryAction) {
    store.state.mainReference.push().set(action.weightEntry.toJson());
  } else if (action is EditEntryAction) {
    store.state.mainReference
        .child(action.weightEntry.key)
        .set(action.weightEntry.toJson());
  } else if (action is RemoveEntryAction) {
    store.state.mainReference.child(action.weightEntry.key).remove();
  } else if (action is UndoRemovalAction) {
    WeightEntry lastRemovedEntry = store.state.lastRemovedEntry;
    store.state.mainReference
        .child(lastRemovedEntry.key)
        .set(lastRemovedEntry.toJson());
  }

  next(action);

  if (action is UserLoadedAction) {
    store.dispatch(new AddDatabaseReferenceAction(FirebaseDatabase.instance
        .reference()
        .child(store.state.firebaseUser.uid)
        .child("entries")
      ..onChildAdded
          .listen((event) => store.dispatch(new OnAddedAction(event)))
      ..onChildChanged
          .listen((event) => store.dispatch(new OnChangedAction(event)))
      ..onChildRemoved
          .listen((event) => store.dispatch(new OnRemovedAction(event)))));
  }
}

ReduxState stateReducer(ReduxState state, action) {
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
