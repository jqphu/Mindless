import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindless/model/app_state.dart';
import 'package:mindless/mindless.dart';

import 'package:mindless/model/task.dart';

class TaskCurrent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        if (model.currentTask == null) {
          return SizedBox.shrink();
        }

        return Container(
          constraints: BoxConstraints(minHeight: 50),
          color: kColorPrimary,
          child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 8,
              ),
              child: TaskTextAndTime(task: model.currentTask)),
        );
      },
    );
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
    return Row(
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
        SizedBox(width: 50),
        Text(
          '${_printDuration(task.totalTimeSpentToday)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        )
      ],
    );
  }
}
