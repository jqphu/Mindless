import 'package:mindless/model/instance.dart';
import 'package:collection/collection.dart';

/// A Single Task
///
/// This task can have multiple instances.
class Task {
  Task(this.name, this._userId, [totalTimeSpentToday]) {
    if (totalTimeSpentToday != null) {
      _totalTimeSpentToday = totalTimeSpentToday;
    }
  }

  int? id;
  final int _userId;

  /// The name of this task.
  String name;

  /// Total time spent on this application.
  ///
  /// This is cumulative of all time.
  Duration _totalTimeSpentToday = Duration();

  /// List of instances for this task.
  List<Instance> instances = [];

  /// Add some elapsed duration for this task.
  void addDuration(Duration time) {
    _totalTimeSpentToday += time;
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
      'time_spent': _totalTimeSpentToday.inSeconds,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  Task.fromMap(Map<String, Object?> map)
      : name = map['name'] as String,
        _userId = map['user_id'] as int,
        id = map['id'] as int,
        _totalTimeSpentToday = Duration(seconds: map['time_spent'] as int);
}
