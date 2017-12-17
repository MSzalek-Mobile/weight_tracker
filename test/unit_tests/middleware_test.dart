import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/middleware.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class StoreMock extends Mock implements Store<ReduxState> {}

class DatabaseReferenceMock extends Mock implements DatabaseReference {}

ReduxState reducerMock(ReduxState state, action) {
  return state;
}

void main() {
  test('middleware AddEntryAction invokes push and set', () {
    //given
    DatabaseReferenceMock firebaseMock = new DatabaseReferenceMock();
    when(firebaseMock.push()).thenReturn(firebaseMock);
    ReduxState state = new ReduxState(
        firebaseState: new FirebaseState(mainReference: firebaseMock));

    Store store = new Store(reducerMock,
        initialState: state, middleware: [middleware].toList());

    WeightEntry weightEntry = new WeightEntry(new DateTime.now(), 70.0, null);
    AddEntryAction action = new AddEntryAction(weightEntry);
    //when
    store.dispatch(action);
    //then
    verify(firebaseMock.push()).called(1);
    verify(firebaseMock.set(weightEntry.toJson())).called(1);
  });

  test('middleware EditEntryAction invokes child and set', () {
    //given
    DatabaseReferenceMock firebaseMock = new DatabaseReferenceMock();
    when(firebaseMock.child(any)).thenReturn(firebaseMock);
    ReduxState state = new ReduxState(
        firebaseState: new FirebaseState(mainReference: firebaseMock));

    Store store = new Store(reducerMock,
        initialState: state, middleware: [middleware].toList());

    WeightEntry weightEntry = new WeightEntry(new DateTime.now(), 70.0, null)
      ..key = "key";
    EditEntryAction action = new EditEntryAction(weightEntry);
    //when
    store.dispatch(action);
    //then
    verify(firebaseMock.child(weightEntry.key)).called(1);
    verify(firebaseMock.set(weightEntry.toJson())).called(1);
  });

  test('middleware RemoveEntryAction invokes child and remove', () {
    //given
    DatabaseReferenceMock firebaseMock = new DatabaseReferenceMock();
    when(firebaseMock.child(any)).thenReturn(firebaseMock);
    ReduxState state = new ReduxState(
        firebaseState: new FirebaseState(mainReference: firebaseMock));

    Store store = new Store(reducerMock,
        initialState: state, middleware: [middleware].toList());

    WeightEntry weightEntry = new WeightEntry(new DateTime.now(), 70.0, null)
      ..key = "key";
    RemoveEntryAction action = new RemoveEntryAction(weightEntry);
    //when
    store.dispatch(action);
    //then
    verify(firebaseMock.child(weightEntry.key)).called(1);
    verify(firebaseMock.remove()).called(1);
  });

  test('middleware UndoRemovalAction invokes child and add', () {
    //given
    WeightEntry weightEntry = new WeightEntry(new DateTime.now(), 70.0, null)
      ..key = "key";
    DatabaseReferenceMock firebaseMock = new DatabaseReferenceMock();
    when(firebaseMock.child(weightEntry.key)).thenReturn(firebaseMock);
    ReduxState state = new ReduxState(
      firebaseState: new FirebaseState(mainReference: firebaseMock),
      removedEntryState: new RemovedEntryState(lastRemovedEntry: weightEntry),
    );

    Store store = new Store(reducerMock,
        initialState: state, middleware: [middleware].toList());

    UndoRemovalAction action = new UndoRemovalAction();
    //when
    store.dispatch(action);
    //then
    verify(firebaseMock.child(weightEntry.key)).called(1);
    verify(firebaseMock.set(weightEntry.toJson())).called(1);
  });
}
