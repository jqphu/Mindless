import 'package:flutter/material.dart';

import 'home.dart';
import 'login/login.dart';

const kColorPrimary = const Color(0xFF48CAE4);
const kColorAccent = const Color(0xFFF1FAEE);
const kColorBrown = const Color(0xFF442B2D);

ThemeData _buildMindlessTheme() {
  final base = ThemeData.light();
  return ThemeData(
    primaryColor: kColorPrimary,
    accentColor: kColorAccent,
    errorColor: Color(0xFFE63947),
    buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kColorAccent,
        colorScheme: base.colorScheme.copyWith(
          secondary: kColorBrown,
        ),
        shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)))),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent,
    ),
    textTheme: base.textTheme.apply(
        fontFamily: 'Rubik', displayColor: kColorBrown, bodyColor: kColorBrown),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: kColorBrown,
        ),
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0))),
    ),
  );
}

class Mindless extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: _buildMindlessTheme(),
        routes: {
          '/': (context) => LoginPage(),
          '/home': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
        });
  }
}
