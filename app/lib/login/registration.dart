import 'package:flutter/material.dart';

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
      body: SafeArea(child: Text("Hello world!")),
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
