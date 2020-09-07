// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'supplemental/cut_corners_border.dart';
import 'package:provider/provider.dart';
import 'model/app_state_model.dart';

import 'home.dart';
import 'colors.dart';
import 'login.dart';

// TODO: Build a Shrine Theme (103)
final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
      accentColor: kShrineBrown900,
      primaryColor: kShrinePink100,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kShrinePink100,
        colorScheme: base.colorScheme.copyWith(
          secondary: kShrineBrown900,
        ),
      ),
      buttonBarTheme: base.buttonBarTheme.copyWith(
        buttonTextTheme: ButtonTextTheme.accent,
      ),
      scaffoldBackgroundColor: kShrineBackgroundWhite,
      cardColor: kShrineBackgroundWhite,
      textSelectionColor: kShrinePink100,
      errorColor: kShrineErrorRed,
      textTheme: _buildShrineTextTheme(base.textTheme),
      primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(color: kShrineBrown900),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: kShrineBrown900,
          ),
        ),
        border: CutCornersBorder(),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: kShrinePink50));
}

// TODO: Build a Shrine Text Theme (103)
TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline5: base.headline5.copyWith(
          fontWeight: FontWeight.w500,
        ),
        headline6: base.headline6.copyWith(fontSize: 18.0),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        bodyText1: base.bodyText1.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: kShrineBrown900,
        bodyColor: kShrineBrown900,
      );
}

class ShrineApp extends StatelessWidget {
  final User user;
  final String taskName;
  final DateTime startedTime;

  ShrineApp(this.user, List<dynamic> list)
      : taskName = list[0],
        startedTime = list[1];

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return MaterialApp(
        title: 'Shrine',
        initialRoute: '/home',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => LoginPage(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/home': (context) =>
              Home(user: user, taskName: taskName, startedTime: startedTime),
        },
        theme: _kShrineTheme,
      );
    } else {
      return MaterialApp(
        title: 'Shrine',
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => LoginPage(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/home': (context) => Home(),
        },
        theme: _kShrineTheme,
      );
    }
  }
}

class Home extends StatelessWidget {
  final User user;
  final String taskName;
  final DateTime startedTime;

  Home({this.user, this.taskName, this.startedTime});

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    var args = ModalRoute.of(context).settings.arguments;

    if (args == null) {
      args = user;
    }

    return ChangeNotifierProvider<AppStateModel>(
      create: (_) => AppStateModel(args, taskName, startedTime)..loadTasks(),
      child: HomePage(),
    );
  }
}

// Route<dynamic> _getRoute(RouteSettings settings) {
//   print("Route is ${settings.name}");
//   switch (settings.name) {
//     case '/':
//       return MaterialPageRoute<void>(
//         settings: settings,
//         builder: (BuildContext context) => LoginPage(),
//         fullscreenDialog: true,
//       );
//     case '/home':
//       final user = settings.arguments;
//       return MaterialPageRoute(builder: (_) => Home(user: user));
//     default:
//       return MaterialPageRoute(
//           builder: (_) => Scaffold(
//               body: Center(
//                   child: Text('No route defined for ${settings.name}'))));
//   }
// }
