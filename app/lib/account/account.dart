import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindless/model/app_state.dart';

class AccountsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Update this page whenever the AppStateModel changes.
    // For now it never changes, but later we can have change username etc.
    var user = context.watch<AppStateModel>();

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
  /// Clear the secure storage login information since we now logged out.
  void _clearLoginSecureStorage() async {
    final storage = FlutterSecureStorage();

    await storage.delete(key: 'username');
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        _clearLoginSecureStorage();

        // Go back to login page.
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text('Logout'),
      ),
    );
  }
}
