import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:weight_tracker/model/weight_entry.dart';

@immutable
class ReduxState {
  final List<WeightEntry> entries;
  final String unit;
  final RemovedEntryState removedEntryState;
  final WeightEntryDialogReduxState weightEntryDialogState;
  final FirebaseState firebaseState;
  final MainPageReduxState mainPageState;
  final DateTime progressChartStartDate;
  final double weightFromNotes;

  const ReduxState({
    this.firebaseState = const FirebaseState(),
    this.entries = const [],
    this.mainPageState = const MainPageReduxState(),
    this.unit = 'kg',
    this.removedEntryState = const RemovedEntryState(),
    this.weightEntryDialogState = const WeightEntryDialogReduxState(),
    this.progressChartStartDate,
    this.weightFromNotes,
  });

  ReduxState copyWith({
    FirebaseState firebaseState,
    List<WeightEntry> entries,
    bool hasEntryBeenAdded,
    String unit,
    RemovedEntryState removedEntryState,
    WeightEntryDialogReduxState weightEntryDialogState,
    DateTime progressChartStartDate,
  }) {
    return new ReduxState(
        firebaseState: firebaseState ?? this.firebaseState,
        entries: entries ?? this.entries,
        mainPageState: mainPageState ?? this.mainPageState,
        unit: unit ?? this.unit,
        weightEntryDialogState:
        weightEntryDialogState ?? this.weightEntryDialogState,
        removedEntryState: removedEntryState ?? this.removedEntryState,
        progressChartStartDate: progressChartStartDate ?? this.progressChartStartDate);
  }
}

@immutable
class RemovedEntryState {
  final WeightEntry lastRemovedEntry;
  final bool hasEntryBeenRemoved; //in other words: should show snackbar?

  const RemovedEntryState(
      {this.lastRemovedEntry, this.hasEntryBeenRemoved = false});

  RemovedEntryState copyWith({
    WeightEntry lastRemovedEntry,
    bool hasEntryBeenRemoved,
  }) {
    return new RemovedEntryState(
        lastRemovedEntry: lastRemovedEntry ?? this.lastRemovedEntry,
        hasEntryBeenRemoved: hasEntryBeenRemoved ?? this.hasEntryBeenRemoved);
  }
}

@immutable
class WeightEntryDialogReduxState {
  final bool isEditMode;
  final WeightEntry activeEntry; //entry to show in detail dialog

  const WeightEntryDialogReduxState({this.isEditMode, this.activeEntry});

  WeightEntryDialogReduxState copyWith({
    bool isEditMode,
    WeightEntry activeEntry,
  }) {
    return new WeightEntryDialogReduxState(
        isEditMode: isEditMode ?? this.isEditMode,
        activeEntry: activeEntry ?? this.activeEntry);
  }
}

@immutable
class FirebaseState {
  final FirebaseUser firebaseUser;
  final DatabaseReference mainReference;

  const FirebaseState({this.firebaseUser, this.mainReference});

  FirebaseState copyWith({
    FirebaseUser firebaseUser,
    DatabaseReference mainReference,
  }) {
    return new FirebaseState(
        firebaseUser: firebaseUser ?? this.firebaseUser,
        mainReference: mainReference ?? this.mainReference);
  }
}

@immutable
class MainPageReduxState {
  final bool hasEntryBeenAdded; //in other words: should scroll to top?

  const MainPageReduxState({this.hasEntryBeenAdded = false});

  MainPageReduxState copyWith({bool hasEntryBeenAdded}) {
    return new MainPageReduxState(
        hasEntryBeenAdded: hasEntryBeenAdded ?? this.hasEntryBeenAdded);
  }
}
