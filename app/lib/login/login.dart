import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';

import 'package:mindless/model/user.dart';
import 'package:mindless/server.dart';
import 'package:logging/logging.dart';

import 'registration.dart';
import 'form_field.dart';

final log = Logger('login');

/// The login logic.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

/// Login page.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  Future<User>? _userRequest;

  // Scaffold.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Handle already stored login information.
    _initializeFromSecureStorage();
  }

  void _resetState() {
    setState(() {
      _userRequest = null;
      _scaffoldKey.currentState!.removeCurrentSnackBar();
    });
  }

  /// Retrieve the data from the secure storage and make a request if data exists.
  void _initializeFromSecureStorage() async {
    final storage = FlutterSecureStorage();

    // Use await here meaning we will block initialization until we read from storage.
    var username = await storage.read(key: 'username');

    if (username != null) {
      _handleLoginAttempt(username);
    }
  }

  void _storeLoginSecureStorage(String username) async {
    final storage = FlutterSecureStorage();

    await storage.write(key: 'username', value: username);
  }

  void _finishSuccessfulLogin(String username) {
    _storeLoginSecureStorage(username);

    setState(() {
      _resetState();
      _usernameController.clear();
    });
  }

  void _handleServerException(exception) {
    _resetState();

    switch (exception.error) {
      case RequestError.NotFound:
        {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RegistrationPage(
                  _usernameController.text, _finishSuccessfulLogin)));
        }
        break;
      // Internal server error. Unexpected!
      default:
        {
          _scaffoldKey.currentState!.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                'Server returned an error. Justin probably broke something!'),
            duration: Duration(seconds: 2),
          ));
        }
        break;
    }
  }

  Future<void> _handleUnexpectedException(exception) {
    _resetState();

    _scaffoldKey.currentState!.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content:
          Text('Something unexpected went wrong :(. Try again? $exception'),
      duration: Duration(seconds: 2),
    ));

    return Future.error('Unexpected exception');
  }

  void _handleLoginAttempt(String username) async {
    // Request is in progress.
    if (_userRequest != null) {
      return;
    }

    setState(() {
      _userRequest = User.login(username);
    });

    await _userRequest!
        .then((user) async {
          log.info('Logging in $user');

          // We don't care about updates, i.e. we don't listen to these values.
          Provider.of<AppStateModel>(context, listen: false).loadUser(user);

          // Reset everything, we are done with login!
          _finishSuccessfulLogin(username);

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
              visible: !connecting,
              child: FloatingActionButton(
                heroTag: 'login',
                onPressed: () async {
                  // Validate the input
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  _handleLoginAttempt(_usernameController.text);
                },
                child: Icon(Icons.navigate_next, size: 50),
              ),
            ),
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
                buildFormField(context, 'Username', 'Fill me in!',
                    widget._usernameController, _usernameFocusNode)
              ])),
        ]));
  }
}
