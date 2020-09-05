import 'package:flutter/material.dart';

import 'home.dart';
import 'login/login.dart';

const kColorBrown = const Color(0xFF442B2D);

ThemeData _buildMindlessTheme() {
  return ThemeData(
      primaryColor: Color(0xFFF1FAEE),
      accentColor: Color(0xFFF7EEFA),
      errorColor: Color(0xFFE63947),
      textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Rubik',
          displayColor: kColorBrown,
          bodyColor: kColorBrown));
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
