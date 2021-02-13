import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:mindless/model/app_state.dart';
import 'package:mindless/model/task.dart';

class TaskRowItem extends StatelessWidget {
  /// The task to display.
  final Task task;

  /// Whether or not this task is the last item.
  ///
  /// This is used to ignore the bottom line separator if it is the last item.
  final bool isLastItem;

  TaskRowItem({@required this.task, @required this.isLastItem})
      : assert(task != null);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(builder: (context, model, child) {
      final row = SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
            right: 8,
          ),
          child: InkWell(
              child: Row(children: <Widget>[
                Expanded(
                    child: Text(
                  task.name,
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                    fontSize: 20,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                  ),
                )),
                MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    // TODO: Starting tasks
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    semanticLabel: 'Options',
                  ),
                ),
              ]),
              onTap: () => model.currentTask = task));

      // Just return the row without the bottom line if it is the last item.
      if (isLastItem) {
        return row;
      }

      return Column(
        children: <Widget>[
          row,
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Container(height: 1, color: Color(0xFFD9D9D9)),
          ),
        ],
      );
    });
  }
}
