/// A Single Task
///
/// This task can have multiple instances.
class Task {
  Task(this._name, this._userId, [totalTimeSpentToday])
      : assert(_name != null) {
    if (totalTimeSpentToday != null) {
      _totalTimeSpentToday = totalTimeSpentToday;
    }
  }

  int _id;
  final int _userId;

  /// The name of this task.
  final String _name;

  /// Total time spent on this application.
  ///
  /// This is cumulative of all time.
  Duration _totalTimeSpentToday = Duration();

  /// Add some elapsed duration for this task.
  void addDuration(Duration time) {
    _totalTimeSpentToday += time;
  }

  Duration get totalTimeSpentToday {
    assert(_totalTimeSpentToday != null);
    return _totalTimeSpentToday;
  }

  set id(int id) => _id = id;
  int get id => _id;
  String get name => _name;

  // Equality determined by name for now.
  @override
  bool operator ==(object) {
    if (object is String) {
      return object.toLowerCase() == name.toLowerCase();
    } else if (object is Task) {
      return object._name.toLowerCase() == name.toLowerCase();
    } else {
      throw 'Unknown comparison operator';
    }
  }

  @override
  int get hashCode => _name.hashCode;

  @override
  String toString() =>
      '$_name (id=$_id) (userId=$_userId) (totalTime:$_totalTimeSpentToday)';

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'user_id': _userId,
      'name': _name,
      'time_spent': _totalTimeSpentToday.inSeconds,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  Task.fromMap(Map<String, Object> map)
      : _name = map['name'],
        _userId = map['user_id'],
        _id = map['id'],
        _totalTimeSpentToday = Duration(seconds: map['time_spent']);
}
