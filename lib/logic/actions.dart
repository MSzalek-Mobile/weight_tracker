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

class AddEntryAction {
  final WeightEntry weightEntry;

  AddEntryAction(this.weightEntry);
}

class EditEntryAction {
  final WeightEntry weightEntry;

  EditEntryAction(this.weightEntry);
}

class RemoveEntryAction {
  final WeightEntry weightEntry;

  RemoveEntryAction(this.weightEntry);
}

class OnAddedAction {
  final Event event;

  OnAddedAction(this.event);
}

class OnChangedAction {
  final Event event;

  OnChangedAction(this.event);
}

class OnRemovedAction {
  final Event event;

  OnRemovedAction(this.event);
}

class AcceptEntryAddedAction {}

class AcceptEntryRemovalAction {}

class UndoRemovalAction {}

class InitAction {}
