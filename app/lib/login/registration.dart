import 'package:flutter/material.dart';
import 'package:mindless/model/user.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';
import 'package:mindless/server.dart';
import 'package:mindless/mindless.dart';

import 'form_field.dart';

class RegistrationPage extends StatefulWidget {
  // Initial username that was passed by the login page.
  final String loginPageUsername;

  // Callback to complete login with a string.
  final Function(String) _finishSuccessfulLoginCallback;

  RegistrationPage(this.loginPageUsername, this._finishSuccessfulLoginCallback);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

/// Registration page.
class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Initialize the username with what was passed in from login page.
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  // Request to register.
  Future<User>? _userRequest;

  @override
  void initState() {
    super.initState();

    // Initialize the username to what was in the login page.
    _usernameController.text = widget.loginPageUsername;
  }

  void _resetState() {
    _userRequest = null;
    _scaffoldKey.currentState!.removeCurrentSnackBar();
  }

  void _handleServerException(exception) {
    _resetState();

    switch (exception.error) {
      case RequestError.AlreadyExists:
        {
          _scaffoldKey.currentState!.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Someone already snagged this username!'),
            duration: Duration(seconds: 2),
          ));
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

  // TODO: de-dup this with the login and other areas.
  void _handleUnexpectedException(exception) {
    _resetState();

    _scaffoldKey.currentState!.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content:
          Text('Something unexpected went wrong :(. Try again? $exception'),
      duration: Duration(seconds: 2),
    ));
  }

  /// Handle a request to register.
  void _handleRegister(String username, String name) {
    // Validate the input
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _userRequest = User.register(username, name);
    });

    _userRequest!
        .then((user) {
          _resetState();
          _usernameController.clear();
          _nameController.clear();

          Provider.of<AppStateModel>(context, listen: false).loadUser(user);

          widget._finishSuccessfulLoginCallback(username);

          Navigator.of(context).pushReplacementNamed('/home', arguments: user);
        })
        // Catch server errors.
        .catchError(_handleServerException, test: (e) => e is RequestException)
        // Catch all other errors.
        .catchError((exception) => _handleUnexpectedException(exception));
  }

  /// Build the registration form field widget if we're not connecting.
  Widget _buildRegistrationFormFieldWidget(bool connecting) {
    if (!connecting) {
      return RegistrationFormField(
          _formKey, _usernameController, _nameController);
    } else {
      return Center(child: CircularProgressIndicator());
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
            appBar: buildMonkeyBar(context, backButton: true),
            body: SafeArea(
                child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    children: <Widget>[
                  SizedBox(height: 140.0),
                  _buildRegistrationFormFieldWidget(connecting)
                ])),
            floatingActionButton: Visibility(
                visible: !connecting,
                child: FloatingActionButton(
                  heroTag: 'register',
                  onPressed: () async {
                    _handleRegister(
                        _usernameController.text, _nameController.text);
                  },
                  child: Icon(Icons.navigate_next, size: 50),
                )),
          );
        });
  }
}

class RegistrationFormField extends StatefulWidget {
  // Form key passed in by the parent.
  final _formKey;

  // Username text controller passed in by the parent.
  final _usernameController;

  // Name text controller passed in by the parent.
  final _nameController;

  RegistrationFormField(
      this._formKey, this._usernameController, this._nameController);

  @override
  _RegistrationFormFieldState createState() => _RegistrationFormFieldState();
}

class _RegistrationFormFieldState extends State<RegistrationFormField> {
  final _usernameFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget._formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          SizedBox(height: 50.0),
          buildFormField(context, 'Username', 'Pick a username! Any username.',
              widget._usernameController, _usernameFocusNode),
          SizedBox(height: 10.0),
          buildFormField(
              context,
              'Name',
              'Did your parents forget to name you?',
              widget._nameController,
              _nameFocusNode),
        ]));
  }
}
