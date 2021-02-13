import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import 'package:mindless/model/app_state.dart';
import 'package:mindless/model/task.dart';

final log = Logger('TaskRowItem');

class TaskRowItem extends StatelessWidget {
  static const double rightOffset = 8;

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
            right: rightOffset,
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
                  onPressed: () async {
                    // Get the Box which is the row.
                    final RenderBox renderBox = context.findRenderObject();

                    // Position of the row itself.
                    final position = renderBox.localToGlobal(Offset.zero);

                    // Size of the row.
                    final size = renderBox.size;
                    await showMenu(
                        context: context,

                        // We use the distance from top to be the position of
                        // the row plus an offset. We use 3/4 of the height so
                        // it starts within the row (easy to tell which item
                        // we're modifying but near the bottom.)
                        //
                        // We use the full width as the size to push it to the
                        // right but use the edge inset from right to match the
                        // inset above.
                        position: RelativeRect.fromLTRB(
                            size.width,
                            position.dy + (size.height * 3) / 4,
                            rightOffset,
                            0),
                        items: [
                          PopupMenuItem<TaskRowOptionTypes>(
                              value: TaskRowOptionTypes.delete,
                              child: Row(
                                children: [
                                  Icon(Icons.delete, semanticLabel: 'Delete'),
                                  SizedBox(width: 10),
                                  Text('Delete')
                                ],
                              )),
                          PopupMenuItem<TaskRowOptionTypes>(
                              value: TaskRowOptionTypes.doNothing,
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb),
                                  SizedBox(width: 10),
                                  Text('Do nothing :)'),
                                ],
                              ))
                        ]).then((taskRowOption) {
                      switch (taskRowOption) {
                        case TaskRowOptionTypes.delete:
                          model.deleteTask(task);
                          break;
                        case TaskRowOptionTypes.doNothing:
                          log.info('Doing nothing :)');
                          break;
                        default:
                          log.info('Nothing selected.');
                      }
                    });
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

// Type of operations on the task row.
enum TaskRowOptionTypes { delete, doNothing }
