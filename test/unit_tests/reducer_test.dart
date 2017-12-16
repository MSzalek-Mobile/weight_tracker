import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class FirebaseUserMock extends Mock implements FirebaseUser {}

class DatabaseReferenceMock extends Mock implements DatabaseReference {}

class EventMock extends Mock implements Event {}

class DataSnapshotMock extends Mock implements DataSnapshot {
  Map<String, dynamic> _data;

  DataSnapshotMock(WeightEntry weightEntry) {
    _data = {
      "key": weightEntry.key,
      "value": {
        "weight": weightEntry.weight,
        "date": weightEntry.dateTime.millisecondsSinceEpoch,
        "note": weightEntry.note
      }
    };
  }

  String get key => _data['key'];

  dynamic get value => _data['value'];
}

void main() {
  test('reducer UserLoadedAction sets firebase user', () {
    //given
    ReduxState initialState = new ReduxState(firebaseUser: null);
    FirebaseUser user = new FirebaseUserMock();
    UserLoadedAction action = new UserLoadedAction(user);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.firebaseUser, user);
  });

  test('reducer AddDatabaseReferenceAction sets database reference', () {
    //given
    ReduxState initialState = new ReduxState(mainReference: null);
    DatabaseReference databaseReference = new DatabaseReferenceMock();
    AddDatabaseReferenceAction action =
    new AddDatabaseReferenceAction(databaseReference);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.mainReference, databaseReference);
  });

  test('reducer AcceptEntryAddedAction sets flag to false', () {
    //given
    ReduxState initialState = new ReduxState(hasEntryBeenAdded: true);
    AcceptEntryAddedAction action = new AcceptEntryAddedAction();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenAdded, false);
  });

  test('reducer AcceptEntryAddedAction flag false stays false', () {
    //given
    ReduxState initialState = new ReduxState(hasEntryBeenAdded: false);
    AcceptEntryAddedAction action = new AcceptEntryAddedAction();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenAdded, false);
  });

  test('reducer AcceptEntryRemovalAction sets flag to false', () {
    //given
    ReduxState initialState = new ReduxState(hasEntryBeenRemoved: true);
    expect(initialState.hasEntryBeenRemoved, true);
    AcceptEntryRemovalAction action = new AcceptEntryRemovalAction();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenRemoved, false);
  });

  test('reducer AcceptEntryRemovalAction flag false stays false', () {
    //given
    ReduxState initialState = new ReduxState(hasEntryBeenRemoved: false);
    AcceptEntryRemovalAction action = new AcceptEntryRemovalAction();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenRemoved, false);
  });

  test('reducer OnUnitChangedAction changes unit', () {
    //given
    ReduxState initialState = new ReduxState(unit: 'initialUnit');
    OnUnitChangedAction action = new OnUnitChangedAction("newUnit");
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.unit, 'newUnit');
  });

  test('reducer UpdateActiveWeightEntry changes entry', () {
    //given
    ReduxState initialState = new ReduxState(activeEntry: null);
    WeightEntry updatedEntry =
    new WeightEntry(new DateTime.now(), 60.0, "text");
    UpdateActiveWeightEntry action = new UpdateActiveWeightEntry(updatedEntry);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.activeEntry, updatedEntry);
  });

  test('reducer OpenEditEntryDialog changes entry', () {
    //given
    ReduxState initialState = new ReduxState(activeEntry: null);
    WeightEntry updatedEntry =
    new WeightEntry(new DateTime.now(), 60.0, "text");
    OpenEditEntryDialog action = new OpenEditEntryDialog(updatedEntry);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.activeEntry, updatedEntry);
  });

  test('reducer OpenEditEntryDialog sets EditMode to true', () {
    //given
    ReduxState initialState = new ReduxState(isEditMode: false);
    WeightEntry updatedEntry =
    new WeightEntry(new DateTime.now(), 60.0, "text");
    OpenEditEntryDialog action = new OpenEditEntryDialog(updatedEntry);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.isEditMode, true);
  });

  test('reducer OpenAddEntryDialog sets EditMode to false', () {
    //given
    ReduxState initialState = new ReduxState(isEditMode: true, entries: []);
    OpenAddEntryDialog action = new OpenAddEntryDialog();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.isEditMode, false);
  });

  test('reducer OpenAddEntryDialog creates new entry with weight 70', () {
    //given
    ReduxState initialState = new ReduxState(activeEntry: null, entries: []);
    OpenAddEntryDialog action = new OpenAddEntryDialog();
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.activeEntry?.weight, 70);
  });

  test(
      'reducer OpenAddEntryDialog creates new entry with copied weight from first entry',
          () {
        //given
        ReduxState initialState = new ReduxState(
            activeEntry: null,
            entries: [new WeightEntry(new DateTime.now(), 60.0, "Text")]);
        OpenAddEntryDialog action = new OpenAddEntryDialog();
        //when
        ReduxState newState = reduce(initialState, action);
        //then
        expect(newState.activeEntry?.weight, 60);
        expect(newState.activeEntry?.note, null);
      });

  test('reducer OnAddedAction adds entry to list', () {
    //given
    WeightEntry entry = createEntry("key", new DateTime.now(), 60.0, null);
    ReduxState initialState = new ReduxState(entries: []);
    OnAddedAction action = new OnAddedAction(createEventMock(entry));
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.entries, contains(entry));
  });

  test('reducer OnAddedAction sets hasEntryBeenAdded to true', () {
    //given
    WeightEntry entry = createEntry("key", new DateTime.now(), 60.0, null);
    ReduxState initialState = new ReduxState(
        entries: [], hasEntryBeenAdded: false);
    OnAddedAction action = new OnAddedAction(createEventMock(entry));
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenAdded, true);
  });

  test('reducer OnRemovedAction sets hasEntryBeenRemoved to true', () {
    //given
    WeightEntry entry = createEntry("key", new DateTime.now(), 60.0, null);
    ReduxState initialState = new ReduxState(
        entries: [entry], hasEntryBeenRemoved: false);
    OnRemovedAction action = new OnRemovedAction(createEventMock(entry));
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.hasEntryBeenRemoved, true);
  });

  test('reducer OnRemovedAction removes entry from list', () {
    //given
    WeightEntry entry = createEntry("key", new DateTime.now(), 60.0, null);
    ReduxState initialState = new ReduxState(entries: [entry]);
    OnRemovedAction action = new OnRemovedAction(createEventMock(entry));
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.entries, isEmpty);
  });

  test('reducer OnRemovedAction sets lastRemovedEntry', () {
    //given
    WeightEntry entry = createEntry("key", new DateTime.now(), 60.0, null);
    ReduxState initialState = new ReduxState(
        entries: [entry], lastRemovedEntry: null);
    OnRemovedAction action = new OnRemovedAction(createEventMock(entry));
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.lastRemovedEntry, entry);
  });
}

WeightEntry createEntry(String key, DateTime dateTime, double weight,
    String note) {
  WeightEntry entry = new WeightEntry(dateTime, weight, note);
  entry.key = key;
  return entry;
}

Event createEventMock(WeightEntry weightEntry) {
  EventMock eventMock = new EventMock();
  DataSnapshotMock snapshotMock = new DataSnapshotMock(weightEntry);
  when(eventMock.snapshot).thenReturn(snapshotMock);
  return eventMock;
}
