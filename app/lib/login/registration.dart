import 'package:flutter/material.dart';
import 'package:mindless/model/user.dart';

import 'form_field.dart';

class RegistrationPage extends StatefulWidget {
  // Initial username that was passed by the login page.
  final String loginPageUsername;

  RegistrationPage(this.loginPageUsername);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

/// Registration page.
class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  // Initialize the username with what was passed in from login page.
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  // Request to register.
  Future<User> _userRequest;

  @override
  void initState() {
    super.initState();

    // Initialize the username to what was in the login page.
    _usernameController.text = widget.loginPageUsername;
  }

  /// Handle a request to register.
  _handleRegister() {
    // Validate the input
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _userRequest =
          User.register(_usernameController.text, _nameController.text);
    });
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
            appBar: buildMonkeyBar(context),
            body: SafeArea(
                child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    children: <Widget>[
                  SizedBox(height: 140.0),
                  _buildRegistrationFormFieldWidget(connecting)
                ])),
            floatingActionButton: Visibility(
                child: FloatingActionButton(
                    heroTag: "register",
                    child: Icon(Icons.navigate_next, size: 50),
                    onPressed: () async {
                      _handleRegister();
                    }),
                visible: !connecting),
          );
        });
  }
}

/// Build the app bar with a monkey and a title.
AppBar buildMonkeyBar(BuildContext context) {
  return AppBar(
    titleSpacing: 0.0,
    title: Row(children: <Widget>[
      Image.asset('assets/monkey.png', height: 40),
      SizedBox(width: 11),
      Text('MINDLESS',
          style: Theme.of(context).textTheme.headline3, textScaleFactor: 0.75),
    ]),
  );
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
          buildFormField(context, "Username", "Pick a username! Any username.",
              widget._usernameController, _usernameFocusNode),
          SizedBox(height: 10.0),
          buildFormField(
              context,
              "Name",
              "Did your parents forget to name you?",
              widget._nameController,
              _nameFocusNode),
        ]));
  }
}
