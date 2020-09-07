import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'task_list_tab.dart';
import 'account_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // TODO: Add a variable for Category (104)
  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            title: Text('Account'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                    middle: Row(
                  children: <Widget>[
                    Image.asset('assets/monkey.png', height: 38),
                    SizedBox(width: 10),
                    Text('MINDLESS',
                        // TODO THEME
                        style: TextStyle(
                            fontFamily: 'Rubik', fontWeight: FontWeight.w400),
                        textScaleFactor: 1.5),
                  ],
                )),
                child: TaskListTab(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                      middle: Row(children: <Widget>[
                    Image.asset('assets/monkey.png', height: 38),
                    SizedBox(width: 10),
                    Text('MINDLESS',
                        // TODO THEME
                        style: TextStyle(
                            fontFamily: 'Rubik', fontWeight: FontWeight.w400),
                        textScaleFactor: 1.5),
                  ])),
                  child: AccountTab());
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
