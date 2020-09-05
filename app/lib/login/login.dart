import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text("Placeholder Login Page"),
        RaisedButton(
            child: Text('Login'),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            })
      ]),
    ));
  }
}
