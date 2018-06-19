import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/redux_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          user: store.state.firebaseState.firebaseUser,
        );
      },
      builder: (BuildContext context, _ViewModel vm) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Profile"),
          ),
          body: new SingleChildScrollView(
            child: new Center(
              child: new Column(
                children: <Widget>[
                  _getUserIcon(vm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getUserIcon(_ViewModel vm) {
    if (vm.user.isAnonymous) {
      return new CircleAvatar(
        backgroundImage: new AssetImage("assets/user_icon.png"),
        radius: 36.0,
      );
    } else {
      return new CircleAvatar(
        backgroundImage: new NetworkImage(vm.user.photoUrl),
        radius: 36.0,
      );
    }
  }
}

class _ViewModel {
  final FirebaseUser user;

  _ViewModel({@required this.user});
}
