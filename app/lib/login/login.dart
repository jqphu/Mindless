import 'package:flutter/material.dart';

/// The login logic.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

/// Login page.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  void _handleNextButtonPress() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    Navigator.of(context).pushNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: <Widget>[
        ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              Title(),
              SizedBox(height: 50),
            ]),
        Expanded(child: LoginField(_formKey, _usernameController)),
      ])),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.navigate_next, size: 50),
          onPressed: () {
            _handleNextButtonPress();
          }),
    );
  }
}

/// Title containing the logo followed by the app name.
class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(height: 80.0),
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
