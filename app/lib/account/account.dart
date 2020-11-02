import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mindless/model/user_state.dart';

class AccountsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Update this page whenever the UserStateModel changes.
    // For now it never changes, but later we can have change username etc.
    var user = context.watch<UserStateModel>();

    return SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: Column(
                // Start at the top
                crossAxisAlignment: CrossAxisAlignment.start,
                // Center horizontally.
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(user.username, textScaleFactor: 1.5),
                  Text(user.name),
                  Divider(color: Colors.grey),
                  LogoutButton(),
                ])));
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        // TODO: Clear local storage and go back to login page.
        print('Received click');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text('Logout'),
      ),
    );
  }
}
