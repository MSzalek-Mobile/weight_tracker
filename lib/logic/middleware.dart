import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/constants.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

final GoogleSignIn _googleSignIn = new GoogleSignIn();

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
  } else if (action is GetSavedWeightNote) {
    _handleGetSavedWeightNote(store);
  } else if (action is AddWeightFromNotes) {
    _handleAddWeightFromNotes(store, action);
  } else if (action is LoginWithGoogle) {
    _handleLoginWithGoogle(store, action);
  } else if (action is LogoutAction) {
    _handleLogoutAction(store, action);
  }
  next(action);
  if (action is UserLoadedAction) {
    _handleUserLoadedAction(store, action);
  } else if (action is AddDatabaseReferenceAction) {
    _handleAddedDatabaseReference(store, action);
  }
}

_handleLogoutAction(Store<ReduxState> store, LogoutAction action) {
  _googleSignIn.signOut();
  FirebaseAuth.instance.signOut().then((_) => FirebaseAuth.instance
      .signInAnonymously()
      .then((user) => store.dispatch(UserLoadedAction(user))));
}

_handleLoginWithGoogle(Store<ReduxState> store, LoginWithGoogle action) async {
  GoogleSignInAccount googleUser = await _getGoogleUser();
  GoogleSignInAuthentication credentials = await googleUser.authentication;

  bool hasLinkingFailed = false;
  try {
    await FirebaseAuth.instance.linkWithGoogleCredential(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  } catch (e) {
    await FirebaseAuth.instance.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
    hasLinkingFailed = true;
  }

  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  await user.updateProfile(new UserUpdateInfo()
    ..photoUrl = googleUser.photoUrl
    ..displayName = googleUser.displayName);
  user.reload();

  store.dispatch(new UserLoadedAction(
    user,
    cachedEntries: hasLinkingFailed ? action.cachedEntries : [],
  ));
}

Future<GoogleSignInAccount> _getGoogleUser() async {
  GoogleSignInAccount googleUser = _googleSignIn.currentUser;
  if (googleUser == null) {
    googleUser = await _googleSignIn.signInSilently();
  }
  if (googleUser == null) {
    googleUser = await _googleSignIn.signIn();
  }
  return googleUser;
}

_handleAddWeightFromNotes(Store<ReduxState> store, AddWeightFromNotes action) {
  if (store.state.firebaseState?.mainReference != null) {
    WeightEntry weightEntry =
        new WeightEntry(new DateTime.now(), action.weight, null);
    store.dispatch(new AddEntryAction(weightEntry));
    action = new AddWeightFromNotes(null);
  }
}

_handleGetSavedWeightNote(Store<ReduxState> store) async {
  double savedWeight = await _getSavedWeightNote();
  if (savedWeight != null) {
    store.dispatch(new AddWeightFromNotes(savedWeight));
  }
}

Future<double> _getSavedWeightNote() async {
  String sharedData = await const MethodChannel('app.channel.shared.data')
      .invokeMethod("getSavedNote");
  if (sharedData != null) {
    int firstIndex = sharedData.indexOf(new RegExp("[0-9]"));
    int lastIndex = sharedData.lastIndexOf(new RegExp("[0-9]"));
    if (firstIndex != -1) {
      String number = sharedData.substring(firstIndex, lastIndex + 1);
      double num = double.parse(number, (error) => null);
      return num;
    }
  }
  return null;
}

_handleAddedDatabaseReference(
    Store<ReduxState> store, AddDatabaseReferenceAction action) {
  //maybe add cached entries
  if (action.cachedEntries?.isNotEmpty ?? false) {
    action.cachedEntries
        .forEach((entry) => store.dispatch(AddEntryAction(entry)));
  }
  //maybe add height from notes
  double weight = store.state.weightFromNotes;
  if (weight != null) {
    if (store.state.unit == 'lbs') {
      weight = weight / KG_LBS_RATIO;
    }
    if (weight >= MIN_KG_VALUE && weight <= MAX_KG_VALUE) {
      WeightEntry weightEntry =
          new WeightEntry(new DateTime.now(), weight, null);
      store.dispatch(new AddEntryAction(weightEntry));
      store.dispatch(new ConsumeWeightFromNotes());
    }
  }
}

_handleUserLoadedAction(Store<ReduxState> store, UserLoadedAction action) {
  store.dispatch(new AddDatabaseReferenceAction(
    FirebaseDatabase.instance
        .reference()
        .child(store.state.firebaseState.firebaseUser.uid)
        .child("entries")
          ..onChildAdded
              .listen((event) => store.dispatch(new OnAddedAction(event)))
          ..onChildChanged
              .listen((event) => store.dispatch(new OnChangedAction(event)))
          ..onChildRemoved
              .listen((event) => store.dispatch(new OnRemovedAction(event))),
    cachedEntries: action.cachedEntries,
  ));
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
  store.state.firebaseState.mainReference
      .child(action.weightEntry.key)
      .remove();
}

_handleEditEntryAction(Store<ReduxState> store, EditEntryAction action) {
  store.state.firebaseState.mainReference
      .child(action.weightEntry.key)
      .set(action.weightEntry.toJson());
}

_handleAddEntryAction(Store<ReduxState> store, AddEntryAction action) {
  store.state.firebaseState.mainReference
      .push()
      .set(action.weightEntry.toJson());
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
