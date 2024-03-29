import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';
import 'package:mindless/mindless.dart';
import 'package:logging/logging.dart';

import 'task_row_item.dart';
import 'task_current.dart';

final log = Logger('TaskTabPage');

class TaskTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        final tasks = model.getTasks();
        return GestureDetector(
            onTap: () {
              log.info('Unfocusing due to touching outside.');
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
                body: SafeArea(
                    child: Column(children: <Widget>[
                  Expanded(
                    // Remove the space between the title and the first element.
                    child: ListView.builder(
                      itemCount: tasks.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index < tasks.length) {
                          return TaskRowItem(
                            task: tasks[index],
                            isLastItem: index == tasks.length - 1,
                          );
                        }

                        return Container();
                      },
                    ),
                  ),
                ])),
                bottomNavigationBar: Padding(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TaskCurrent(),
                        Divider(
                          height: 0.2,
                        )
                      ],
                    )),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                floatingActionButton: FloatingActionButton(
                  backgroundColor: kColorPrimary,
                  onPressed: () async {
                    await Navigator.of(context).pushNamed('/search');
                  },
                  child: const Icon(
                    Icons.add,
                    color: kColorBrown,
                  ),
                )));
      },
    );
  }
}
