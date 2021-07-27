import 'package:mindless/model/instance.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

final log = Logger('task');

/// A Single Task
///
/// This task can have multiple _instances.
class Task {
  Task(this.name, this._userId);

  int? id;
  final int _userId;

  /// The name of this task.
  String name;

  /// Total time spent on this application.
  ///
  /// This is cumulative of all time.
  Duration _totalTimeSpentToday = Duration();

  /// List of _instances for this task.
  List<Instance> _instances = [];

  Instance lastInstance() {
    return _instances.last;
  }

  /// Start this task.
  ///
  /// Assumes nothing is running.
  Instance start() {
    assert(_instances.isEmpty || !_instances.last.isActive);

    var startedInstance = Instance(this, DateTime.now(), true);
    _instances.add(startedInstance);

    return startedInstance;
  }

  /// End the current task
  ///
  /// Assumes something is running.
  Instance end() {
    assert(_instances.isNotEmpty && _instances.last.isActive);
    _instances.last.end();
    return _instances.last;
  }

  /// Add some elapsed duration for this task.
  ///
  /// This only exists as a convenience function (TODO remove, move this to the model itself.)
  void addDuration(Duration time) {
    _totalTimeSpentToday += time;
  }

  void addInstances(List<Instance> instances) {
    log.finer('Adding instances $instances');
    _instances = instances;
    for (var instance in _instances) {
      _totalTimeSpentToday += instance.timeSpent;
    }
  }

  Duration get totalTimeSpentToday {
    return _totalTimeSpentToday;
  }

  // Equality determined by name for now.
  @override
  bool operator ==(object) {
    if (object is String) {
      return object.toLowerCase() == name.toLowerCase();
    } else if (object is Task) {
      return object.name.toLowerCase() == name.toLowerCase();
    } else {
      throw 'Unknown comparison operator';
    }
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      '$name (id=$id) (userId=$_userId) (totalTime:$_totalTimeSpentToday)';

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'user_id': _userId,
      'name': name,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  Task.fromMap(Map<String, Object?> map)
      : name = map['name'] as String,
        _userId = map['user_id'] as int,
        id = map['id'] as int;
}
