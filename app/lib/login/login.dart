import 'package:flutter/material.dart';

import 'package:mindless/model/user.dart';
import 'package:mindless/server.dart';

import 'registration.dart';

/// The login logic.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

/// Login page.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  Future<User> _userRequest;

  // Scaffold.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _resetState() {
    _userRequest = null;
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  void _handleServerException(exception) {
    _resetState();

    switch (exception.error) {
      case RequestError.NotFound:
        {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RegistrationPage()));
        }
        break;
      // Internal server error. Unexpected!
      default:
        {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                "Server returned an error. Justin probably broke something!"),
            duration: Duration(seconds: 2),
          ));
        }
        break;
    }
  }

  void _handleUnexpectedException(exception) {
    _resetState();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content:
          Text("Something unexpected went wrong :(. Try again? $exception"),
      duration: Duration(seconds: 2),
    ));
  }

  void _handleNextButtonPress() async {
    // Request is in progress.
    if (_userRequest != null) {
      return;
    }

    // Validate the input
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _userRequest = User.login(_usernameController.text);
    });

    _userRequest
        .then((user) {
          _userRequest = null;
          _usernameController.clear();

          Navigator.of(context).pushNamed('/home', arguments: user);
        })
        // Catch server errors.
        .catchError(_handleServerException, test: (e) => e is RequestException)
        // Catch all other errors.
        .catchError((exception) => _handleUnexpectedException(exception));
  }

  /// Build the login field widget if we're not connecting.
  Widget _buildLoginFieldWidget(bool connecting) {
    if (!connecting) {
      return Expanded(child: LoginField(_formKey, _usernameController));
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _userRequest,
        builder: (context, snapshot) {
          final connecting =
              snapshot.connectionState == ConnectionState.waiting;

          return Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
                child: Column(children: <Widget>[
              SizedBox(height: 80.0),
              Title(),
              SizedBox(height: 50),
              _buildLoginFieldWidget(connecting),
            ])),
            floatingActionButton: Visibility(
                child: FloatingActionButton(
                    heroTag: "test",
                    child: Icon(Icons.navigate_next, size: 50),
                    onPressed: () async {
                      _handleNextButtonPress();
                    }),
                visible: !connecting),
          );
        });
  }
}

/// Title containing the logo followed by the app name.
class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Image.asset('assets/monkey.png', height: 100),
      Center(
          child:
              Text('MINDLESS', style: Theme.of(context).textTheme.headline3)),
    ]);
  }
}

/// The login logic.
class LoginField extends StatefulWidget {
  // Form key passed in by the parent.
  final _formKey;

  // Username text controller passed in by the parent.
  final _usernameController;

  LoginField(this._formKey, this._usernameController);

  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  // State controlling user input
  final _unfocusedColor = Colors.grey[600];
  final _usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      // Redraw every-time the username focus state changes.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget._formKey,
        child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: <Widget>[
                TextFormField(
                    controller: widget._usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: _usernameFocusNode.hasFocus
                              ? Theme.of(context).accentColor
                              : _unfocusedColor),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Fill me in!";
                      }

                      return null;
                    })
              ])),
        ]));
  }
}
