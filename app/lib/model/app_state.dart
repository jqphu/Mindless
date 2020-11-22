import 'package:flutter/foundation.dart';
import 'task_respository.dart';
import 'user.dart';
import 'task.dart';

class AppStateModel extends ChangeNotifier {
  /// User that is logged in. The user never is cleared.
  final User _user;

  /// List of tasks.
  List<Task> _tasks;

  /// Optional Current task.
  Task _currentTask;

  /// Initialize the AppStateModel with the user.
  AppStateModel(this._user) {
    assert(_user != null);
    _tasks = List();
    _currentTask = null;
  }

  String get username => _user.username;
  String get name => _user.name;
  Task get currentTask => _currentTask;

  // Loads the list of available products from the repo.
  void loadTasks() async {
    _tasks = await TasksRepository.loadTasks(_user.id);
    _currentTask = _tasks[2];
    notifyListeners();
  }

  // Returns a copy of the list of the current tasks.
  List<Task> getTasks() {
    return _tasks;
  }
}
