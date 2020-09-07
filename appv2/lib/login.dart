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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'model/user.dart';
import 'register.dart';
import 'server.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TODO: Make this smarter.
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // TODO: Add text editing controllers (101)
  final _usernameController = TextEditingController();
  final _unfocusedColor = Colors.grey[600];
  final _usernameFocusNode = FocusNode();

  var name;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      setState(() {
        //Redraw so that the username label reflects the focus state
      });
    });
  }

  // TODO: Add text editing controllers (101)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
          child: Column(children: <Widget>[
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('assets/monkey.png', height: 100),
                  Text('MINDLESS',
                      style: Theme.of(context).textTheme.headline3),
                  SizedBox(height: 50.0),
                  // TODO: Add TextField widgets (101)
                  // [Name]
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
                      }),
                  // TODO: Add button bar (101)
                  ButtonBar(
                    // TODO: Add a beveled rectangular border to CANCEL (103)
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Login'),
                        elevation: 8.0,
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // NO HTTP REQUEST, just testing the app.
                            if (_usernameController.text == "no_request") {
                              Navigator.of(context).pop();
                              _usernameController.clear();
                            }

                            await User.login(_usernameController.text)
                                .then((user) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('name', user.name);
                              prefs.setInt('id', user.id);
                              prefs.setString('username', user.username);
                              Navigator.pushNamed(context, '/home',
                                  arguments: user);
                              _usernameController.clear();
                            }).catchError((exception) {
                              print("Error occured: ${exception.error}");
                              switch (exception.error) {
                                case RequestError.NotFound:
                                  {
                                    _scaffoldKey.currentState
                                        .removeCurrentSnackBar();
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                          "Hmm, I couldn't find the user ${_usernameController.text}.",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                              }
                            }, test: (e) => e is RequestException).catchError(
                                    (exception) {
                              // Clear the old snackbar if one existed.
                              _scaffoldKey.currentState.removeCurrentSnackBar();
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                    "Something went wrong :(. Try again? Error: ${exception})",
                                    style: Theme.of(context).textTheme.caption),
                                duration: Duration(seconds: 2),
                              ));
                            });
                          }
                        },
                      ),
                      // TODO: Add buttons (101)
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        Expanded(
            child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: RaisedButton(
            child: Text('Register'),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
            ),
            onPressed: () async {
              // TODO: Clear the text fields (101)
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );

              if (result != null) {
                final username = result[0];
                name = result[1];
                print(result);
                print(name);

                _usernameController.text = username;

                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Let\'s get this party started $name!',
                      style: Theme.of(context).textTheme.caption),
                  duration: Duration(seconds: 3),
                ));
              }
            },
          ),
        )),
        SizedBox(height: 50.0),
      ])),
    );
  }
}
// TODO: Add AccentColorOverride (103)
