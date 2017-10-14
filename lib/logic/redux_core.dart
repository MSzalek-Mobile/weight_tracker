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
  final bool hasEntryBeenAdded;

  ReduxState({this.firebaseUser,
    this.mainReference,
    this.entries,
    this.hasEntryBeenAdded});

  ReduxState copyWith({FirebaseUser firebaseUser,
    DatabaseReference mainReference,
    List<WeightEntry> entries,
    bool hasEntryBeenAdded}) {
    return new ReduxState(
        firebaseUser: firebaseUser ?? this.firebaseUser,
        mainReference: mainReference ?? this.mainReference,
        entries: entries ?? this.entries,
        hasEntryBeenAdded: hasEntryBeenAdded ?? this.hasEntryBeenAdded);
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
          .listen((event) => store.dispatch(new OnChangedAction(event)))));
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
  } else if (action is AcceptEntryAddedAction) {
    newState = state.copyWith(hasEntryBeenAdded: false);
  }
  return newState;
}

ReduxState _onEntryAdded(ReduxState state, Event event) {
  return state.copyWith(
    hasEntryBeenAdded: true,
    entries: <WeightEntry>[]
      ..addAll(state.entries)
      ..add(new WeightEntry.fromSnapshot(event.snapshot))
      ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime)),
  );
}

ReduxState _onEntryEdited(ReduxState state, Event event) {
  var oldValue =
      state.entries.singleWhere((entry) => entry.key == event.snapshot.key);
  return state.copyWith(
    entries: <WeightEntry>[]
      ..addAll(state.entries)
      ..[state.entries.indexOf(oldValue)] =
      new WeightEntry.fromSnapshot(event.snapshot)
      ..sort((we1, we2) => we2.dateTime.compareTo(we1.dateTime)),
  );
}
