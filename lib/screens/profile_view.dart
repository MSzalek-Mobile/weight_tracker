import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          user: store.state.firebaseState.firebaseUser,
          login: () => store
              .dispatch(LoginWithGoogle(cachedEntries: store.state.entries)),
          logout: () => store.dispatch(LogoutAction()),
        );
      },
      builder: (BuildContext context, _ViewModel vm) {
        return (vm.user?.isAnonymous ?? true)
            ? _anonymousView(context, vm)
            : _loggedInView(context, vm);
      },
    );
  }

  Widget _loggedInView(BuildContext context, _ViewModel vm) {
    return Column(
      children: <Widget>[
        _drawAvatar(NetworkImage(vm.user.photoUrl)),
        _drawLabel(context, vm.user.displayName),
        Text(vm.user.email),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            width: 120.0,
            child: RaisedButton(
              color: Colors.green,
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: vm.logout,
            ),
          ),
        )
      ],
    );
  }

  Widget _anonymousView(BuildContext context, _ViewModel vm) {
    return Column(
      children: <Widget>[
        _drawAvatar(AssetImage('assets/user.png')),
        _drawLabel(context, 'Anonymous user'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'To synchronize your data across all devices link your data with a Google account.',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: OAuthLoginButton(
            onPressed: vm.login,
            text: 'Continue with Google',
            assetName: 'assets/google.png',
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Padding _drawLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }

  Padding _drawAvatar(ImageProvider imageProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: CircleAvatar(
        backgroundImage: imageProvider,
        backgroundColor: Colors.white10,
        radius: 48.0,
      ),
    );
  }
}

class _ViewModel {
  final FirebaseUser user;
  final Function() login;
  final Function() logout;

  _ViewModel({
    @required this.user,
    @required this.login,
    @required this.logout,
  });
}

class OAuthLoginButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final String assetName;
  final Color backgroundColor;

  OAuthLoginButton(
      {@required this.onPressed,
      @required this.text,
      @required this.assetName,
      @required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 240.0,
      child: new RaisedButton(
        color: backgroundColor,
        onPressed: onPressed,
        padding: new EdgeInsets.only(right: 8.0),
        child: new Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Image.asset(
                assetName,
                height: 30.0,
              ),
            ),
            new Expanded(
                child: new Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new Text(
                text,
                style: Theme.of(context).textTheme.button,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
