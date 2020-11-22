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
          child: Dismissible(
            key: Key(task.name),
            background: Container(color: Colors.redAccent),
            onDismissed: (direction) {
              // TODO: Removing tasks.
            },
            child: Row(
              children: <Widget>[
                Expanded(child: TaskTextAndTime(task: task)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // TODO: Starting tasks
                  },
                  child: Icon(
                    CupertinoIcons.play_arrow,
                    semanticLabel: 'Start',
                  ),
                ),
              ],
            ),
          ));

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

class TaskTextAndTime extends StatelessWidget {
  final Task task;
  TaskTextAndTime({@required this.task}) : assert(task != null);

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          task.name,
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.8),
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        Text(
          '${_printDuration(task.totalTimeSpentToday)}',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        )
      ],
    );
  }
}
