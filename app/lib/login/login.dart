import 'package:flutter/material.dart';

/// Login page.
class LoginPage extends StatelessWidget {
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
      Expanded(child: LoginField()),
    ])));
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
  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  // State controlling user input
  final _usernameController = TextEditingController();
  final _unfocusedColor = Colors.grey[600];
  final _usernameFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

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
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: <Widget>[
                TextFormField(
                    controller: _usernameController,
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
          Expanded(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: FloatingActionButton(
                        child: Icon(Icons.navigate_next, size: 50),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/home');
                        }),
                  )))
        ]));
  }
}
