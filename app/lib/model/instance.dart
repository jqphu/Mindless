import 'package:mindless/model/task.dart';

/// A Single Instance
class Instance {
  Instance(this._task, this._startedAt, [timeSpent])
      : assert(_task != null),
        assert(_startedAt != null) {
    if (timeSpent != null) {
      _timeSpent = timeSpent;
    }
  }

  int _id;

  /// Parent task.
  final Task _task;

  /// Started at instance.
  final DateTime _startedAt;

  /// Time spent on this instance.
  Duration _timeSpent = Duration();

  @override
  String toString() =>
      '$_startedAt (id=$_id) (timeSpent=$_timeSpent) (task=$_task)';

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'task_id': _task.id,
      'started_at': _startedAt.millisecondsSinceEpoch,
      'time_spent': _timeSpent.inSeconds,
    };

    if (_id != null) {
      map['id'] = _id;
    }

    return map;
  }

  Instance.fromMap(Map<String, Object> map)
      : _id = map['id'],
        _task = map['task'],
        _startedAt = DateTime.fromMillisecondsSinceEpoch(map['started_at']),
        _timeSpent = Duration(seconds: map['time_spent']);
}
