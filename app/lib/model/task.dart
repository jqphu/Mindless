/// A Single Task
///
/// This task can have multiple instances.
class Task {
  Task(this._name, this._userId, [this._totalTimeSpentToday])
      : assert(_name != null);

  int _id;
  final int _userId;

  /// The name of this task.
  final String _name;

  /// Total time spent on this application.
  ///
  /// This is cumulative of all time.
  final Duration _totalTimeSpentToday;

  Duration get totalTimeSpentToday {
    assert(_totalTimeSpentToday != null);
    return _totalTimeSpentToday;
  }

  int get id => _id;
  String get name => _name;

  // Equality determined by name for now.
  @override
  bool operator ==(otherTask) => otherTask._name == _name;

  @override
  int get hashCode => _name.hashCode;

  @override
  String toString() => '$_name (id=$_id) (userId=$_userId)';
}
