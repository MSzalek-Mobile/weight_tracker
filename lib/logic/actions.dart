import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class UserLoadedAction {
  final FirebaseUser firebaseUser;
  final List<WeightEntry> cachedEntries;

  UserLoadedAction(this.firebaseUser, {this.cachedEntries = const []});
}

class AddDatabaseReferenceAction {
  final DatabaseReference databaseReference;
  final List<WeightEntry> cachedEntries;

  AddDatabaseReferenceAction(this.databaseReference,
      {this.cachedEntries = const []});
}

class GetSavedWeightNote {}

class AddWeightFromNotes {
  final double weight;

  AddWeightFromNotes(this.weight);
}

class ConsumeWeightFromNotes {}

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

class SetUnitAction {
  final String unit;

  SetUnitAction(this.unit);
}

class OnUnitChangedAction {
  final String unit;

  OnUnitChangedAction(this.unit);
}

class UpdateActiveWeightEntry {
  final WeightEntry weightEntry;

  UpdateActiveWeightEntry(this.weightEntry);
}

class OpenAddEntryDialog {}

class OpenEditEntryDialog {
  final WeightEntry weightEntry;

  OpenEditEntryDialog(this.weightEntry);
}

class ChangeProgressChartStartDate {
  final DateTime dateTime;

  ChangeProgressChartStartDate(this.dateTime);
}

class LoginWithGoogle {
  final List<WeightEntry> cachedEntries;

  LoginWithGoogle({this.cachedEntries = const []});
}

class LogoutAction {
  LogoutAction();
}
