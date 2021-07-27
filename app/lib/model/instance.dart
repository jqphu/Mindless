import 'package:mindless/model/task.dart';
import 'package:logging/logging.dart';

final log = Logger('instance');

/// A Single Instance
class Instance {
  Instance(this._task, this._startedAt, this._isActive);

  int? id;

  /// Parent task.
  final Task _task;

  /// Started at instance.
  final DateTime _startedAt;

  /// Time spent on this instance.
  Duration _timeSpent = Duration();

  /// Whether this instance is running.
  bool _isActive;

  /// End this instance, it should not be mutated after this.
  void end() {
    assert(isActive);
    _isActive = false;
    _timeSpent = DateTime.now().difference(_startedAt);
    log.fine('Ending instance $this');
  }

  Duration get timeSpent {
    if (_isActive) {
      _timeSpent = DateTime.now().difference(_startedAt);
    }

    return _timeSpent;
  }

  bool get isActive => _isActive;

  @override
  String toString() =>
      '$_startedAt (id=$id) (timeSpent=$_timeSpent) (task=$_task)';

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'task_id': _task.id!,
      'started_at': _startedAt.millisecondsSinceEpoch,
      'time_spent': _timeSpent.inMilliseconds,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  Instance.fromMap(Map<String, Object?> map, Task task)
      : id = map['id'] as int,
        _startedAt =
            DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
        _task = task,
        _isActive = false,
        _timeSpent = Duration(milliseconds: map['time_spent'] as int) {
    if (_timeSpent == Duration.zero) {
      log.info('Task $task is active');
      _isActive = true;
    }
  }
}
