import 'package:flutter/material.dart';
import 'package:mindless/mindless.dart';
import 'package:provider/provider.dart';

import 'model/user_state.dart';
import 'model/user.dart';
import 'account/account.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// The user is always passed in.
    final User user = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
        length: 2,
        child: ChangeNotifierProvider<UserStateModel>(
            create: (context) => UserStateModel(user),
            child: Scaffold(
                appBar: buildMonkeyBar(context),
                bottomNavigationBar: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.account_circle)),
                  ],
                ),
                body: TabBarView(
                    children: [Icon(Icons.home), AccountsTabPage()]))));
  }
}
