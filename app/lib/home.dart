import 'package:flutter/material.dart';
import 'package:mindless/mindless.dart';

import 'tasks/task_tab_page.dart';
import 'account/account.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: buildMonkeyBar(context, backButton: false),
            bottomNavigationBar: Container(
                color: kColorPrimary,
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.account_circle)),
                  ],
                )),
            body: TabBarView(children: [TaskTabPage(), AccountsTabPage()])));
  }
}
