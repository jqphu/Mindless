import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'login/login.dart';
import 'tasks/search_page.dart';
import 'model/app_state.dart';

const kColorPrimary = Color(0xFFF1FAEE);
const kColorAccent = Color(0xFF48CAE4);
const kColorBrown = Color(0xFF442B2D);

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
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kColorPrimary,
      contentTextStyle: TextStyle(color: kColorBrown),
      elevation: 6,
    ),
  );
}

class Mindless extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateModel>(
        create: (context) => AppStateModel(),
        child: MaterialApp(
            title: 'Mindless',
            theme: _buildMindlessTheme(),
            routes: {
              '/': (context) => LoginPage(),
              '/home': (context) => HomePage(),
              '/search': (context) => SearchPage(),
            }));
  }
}

/// Build the app bar with a monkey and a title.
AppBar buildMonkeyBar(BuildContext context, {required bool backButton}) {
  return AppBar(
    automaticallyImplyLeading: backButton,
    titleSpacing: 0.0,
    title: Row(children: <Widget>[
      SizedBox(width: 10),
      Image.asset('assets/monkey.png', height: 40),
      SizedBox(width: 10),
      Text('MINDLESS',
          style: Theme.of(context).textTheme.headline3, textScaleFactor: 0.75),
    ]),
  );
}
