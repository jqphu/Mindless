import 'package:flutter/material.dart';

/// Login page.
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                children: <Widget>[Title(), LoginButtonBar()])));
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
class LoginButtonBar extends StatefulWidget {
  @override
  _LoginButtonBarState createState() => _LoginButtonBarState();
}

class _LoginButtonBarState extends State<LoginButtonBar> {
  // State controlling user input
  final _usernameController = TextEditingController();
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
    return RaisedButton(
        child: Text('Login'),
        onPressed: () {
          Navigator.pushNamed(context, '/home');
        });
  }
}
