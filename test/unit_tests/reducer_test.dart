import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/reducer.dart';
import 'package:weight_tracker/logic/redux_state.dart';

class FirebaseUserMock extends Mock implements FirebaseUser {}

void main() {
  test('reducer user loaded test', () {
    //given
    ReduxState initialState = new ReduxState();
    FirebaseUser user = new FirebaseUserMock();
    UserLoadedAction action = new UserLoadedAction(user);
    expect(initialState.firebaseUser, null);
    //when
    ReduxState newState = reduce(initialState, action);
    //then
    expect(newState.firebaseUser, user);
  });
}
