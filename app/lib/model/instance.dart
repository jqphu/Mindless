import 'package:mindless/model/task.dart';

/// A Single Instance
class Instance {
  Instance(this._task, this._startedAt, [timeSpent]) {
    if (timeSpent != null) {
      _timeSpent = timeSpent;
    }
  }

  int? id;

  /// Parent task.
  final Task _task;

  /// Started at instance.
  final DateTime _startedAt;

  /// Time spent on this instance.
  Duration _timeSpent = Duration();

  @override
  String toString() =>
      '$_startedAt (id=$id) (timeSpent=$_timeSpent) (task=$_task)';

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'task_id': _task.id!,
      'started_at': _startedAt.millisecondsSinceEpoch,
      'time_spent': _timeSpent.inSeconds,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  Instance.fromMap(Map<String, Object> map)
      : id = map['id'] as int,
        _task = map['task'] as Task,
        _startedAt =
            DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
        _timeSpent = Duration(seconds: map['time_spent'] as int);
}
