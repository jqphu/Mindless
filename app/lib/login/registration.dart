import 'package:flutter/material.dart';

import 'form_field.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

/// Registration page.
class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMonkeyBar(context),
      body: SafeArea(
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
            SizedBox(height: 140.0),
            RegistrationFormField()
          ])),
    );
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
  @override
  _RegistrationFormFieldState createState() => _RegistrationFormFieldState();
}

class _RegistrationFormFieldState extends State<RegistrationFormField> {
  final _usernameFocusNode = FocusNode();
  final _usernameController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      SizedBox(height: 50.0),
      buildFormField(context, "Username", "Pick a username! Any username.",
          _usernameController, _usernameFocusNode),
      SizedBox(height: 10.0),
      buildFormField(context, "Name", "Did your parents forget name you?",
          _nameController, _nameFocusNode),
    ]));
  }
}
