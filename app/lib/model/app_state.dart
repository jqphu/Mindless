import 'package:flutter/foundation.dart';
import 'task_respository.dart';
import 'user.dart';
import 'task.dart';

class AppStateModel extends ChangeNotifier {
  /// User that is logged in. The user never is cleared.
  User _user;

  /// List of tasks.
  List<Task> _tasks;

  /// Optional Current task.
  Task _currentTask;

  /// Initialize the AppStateModel with the user.
  AppStateModel() {
    _user = null;
    _tasks = [];
    _currentTask = null;
  }

  String get username => _user.username;
  String get name => _user.name;
  Task get currentTask => _currentTask;

  set user(User user) {
    _user = user;

    // After logging in load the tasks.
    _loadTasks();

    notifyListeners();
  }

  set currentTask(Task task) {
    _currentTask = task;

    notifyListeners();
  }

  // Loads the list of available products from the repo.
  void _loadTasks() async {
    _tasks = await TasksRepository.loadTasks(_user.id);
    _currentTask = _tasks[2];
    notifyListeners();
  }

  // Returns a copy of the list of the current tasks.
  List<Task> getTasks() {
    return _tasks;
  }

  // Add a task
  Future<Task> addTask(String taskName) async {
    return Future.delayed(Duration(seconds: 2), () => Task(taskName, _user.id))
        .then((result) {
      _tasks.add(result);
      return result;
    });
  }
}
