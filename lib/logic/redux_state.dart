import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:weight_tracker/model/weight_entry.dart';

@immutable
class ReduxState {
  final FirebaseUser firebaseUser;
  final DatabaseReference mainReference;
  final List<WeightEntry> entries;
  final bool hasEntryBeenAdded; //in other words: should scroll to top?
  final WeightEntry lastRemovedEntry;
  final bool hasEntryBeenRemoved; //in other words: should show snackbar?
  final String unit;
  final bool isEditMode;
  final WeightEntry activeEntry; //entry to show in detail dialog

  ReduxState(
      {this.firebaseUser,
      this.mainReference,
      this.entries,
      this.hasEntryBeenAdded,
      this.lastRemovedEntry,
      this.hasEntryBeenRemoved,
      this.unit,
        this.activeEntry,
        this.isEditMode});

  ReduxState copyWith(
      {FirebaseUser firebaseUser,
      DatabaseReference mainReference,
      List<WeightEntry> entries,
      bool hasEntryBeenAdded,
      WeightEntry lastRemovedEntry,
      bool hasEntryBeenRemoved,
      String unit,
        WeightEntry activeEntry,
        bool isEditMode}) {
    return new ReduxState(
        firebaseUser: firebaseUser ?? this.firebaseUser,
        mainReference: mainReference ?? this.mainReference,
        entries: entries ?? this.entries,
        hasEntryBeenAdded: hasEntryBeenAdded ?? this.hasEntryBeenAdded,
        lastRemovedEntry: lastRemovedEntry ?? this.lastRemovedEntry,
        hasEntryBeenRemoved: hasEntryBeenRemoved ?? this.hasEntryBeenRemoved,
        unit: unit ?? this.unit,
        activeEntry: activeEntry ?? this.activeEntry,
        isEditMode: isEditMode ?? this.isEditMode);
  }
}
