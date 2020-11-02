import 'package:flutter/material.dart';
import 'login/registration.dart';

import 'model/user.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// The user is always passed in.
    final User user = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: buildMonkeyBar(context),
            bottomNavigationBar: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_circle)),
              ],
            ),
            body: TabBarView(children: [
              Icon(Icons.home),
              Icon(Icons.account_circle),
            ])));
  }
}
