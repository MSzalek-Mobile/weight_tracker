import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class UserLoadedAction {
  final FirebaseUser firebaseUser;

  UserLoadedAction(this.firebaseUser);
}

class AddDatabaseReferenceAction {
  final DatabaseReference databaseReference;

  AddDatabaseReferenceAction(this.databaseReference);
}

class LocalAddAction {
  final WeightEntry weightEntry;

  LocalAddAction(this.weightEntry);
}

class LocalEditAction {
  final WeightEntry weightEntry;

  LocalEditAction(this.weightEntry);
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

class InitAction {}
