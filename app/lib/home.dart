import 'package:flutter/material.dart';
import 'package:mindless/mindless.dart';
import 'package:provider/provider.dart';

import 'model/app_state.dart';
import 'tasks/task_tab_page.dart';
import 'model/user.dart';
import 'account/account.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// The user is always passed in.
    final User user = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
        length: 2,
        child: ChangeNotifierProvider<AppStateModel>(
            create: (context) => AppStateModel(user)..loadTasks(),
            child: Scaffold(
                appBar: buildMonkeyBar(context),
                bottomNavigationBar: Container(
                    color: kColorPrimary,
                    child: TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.home)),
                        Tab(icon: Icon(Icons.account_circle)),
                      ],
                    )),
                body:
                    TabBarView(children: [TaskTabPage(), AccountsTabPage()]))));
  }
}
