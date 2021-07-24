import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'dart:async';

import 'database_repository.dart';
import 'user.dart';
import 'task.dart';

final log = Logger('AppState');

class AppStateModel extends ChangeNotifier {
  /// The SQLite database.
  TaskDatabase database = TaskDatabase();

  /// User that is logged in. The user never is cleared.
  User _user;

  /// List of tasks.
  List<Task> _tasks;

  /// Optional Current task.
  Task _currentTask;

  /// Initialize the AppStateModel with the user.
  AppStateModel() {
    reset();
    Timer.periodic(Duration(seconds: 1), (Timer t) async {
      if (_currentTask != null) {
        _currentTask.addDuration(Duration(seconds: 1));
        notifyListeners();
      }
    });
  }

  String get username => _user.username;
  String get name => _user.name;
  Task get currentTask => _currentTask;

  // Reset AppStateModel
  void reset() {
    _user = null;
    _tasks = [];
    _currentTask = null;
  }

  set user(User user) {
    // TODO: Initialize different DB for each user.

    database.initialize(user).then((user) {
      log.finer('Update user to $user');
      _user = user;
      _currentTask = user.currentTask;

      // After logging in load the tasks.
      _loadTasks();

      notifyListeners();
    });
  }

  set currentTask(Task task) {
    log.finer('Starting current task $task current is ${_user.currentTask}');

    // Update current task state.
    final now = DateTime.now();
    if (_currentTask != task && _currentTask != null) {
      database.update(_currentTask);
    }

    // Update the user to the new task.
    _user.currentTask = task;
    _currentTask = task;

    // Reset starting task now.
    _user.startedAt = now;

    database.updateUser(_user);

    notifyListeners();
  }

  // Loads the list of available products from the repo.
  void _loadTasks() async {
    _tasks = await database.loadTasks(_user.id);
    notifyListeners();
  }

  // Returns a copy of the list of the current tasks.
  List<Task> getTasks() {
    return _tasks;
  }

  // Delete a task
  //
  // Returns true if task was found and deleted, false when task wasn't found.
  Future<bool> deleteTask(Task task) async {
    if (task == _user.currentTask) {
      currentTask = null;
    }

    final found = _tasks.remove(task);

    notifyListeners();

    if (found) {
      log.info('Task $task was removed.');
      await database.delete(task);
    } else {
      log.warning('Task $task was not removed.');
    }

    return found;
  }

  // Rename a task
  Future<void> renameTask(Task task, String name) async {
    task.name = name;
    await database.update(task);

    notifyListeners();
  }

  // Add a task.
  //
  // Returns the new task. This may not add the task if it already exists.
  Future<Task> addTask(String taskName) async {
    var foundTask = _tasks.singleWhere((Task task) => task.name == taskName,
        orElse: () => null);
    if (foundTask != null) {
      log.info('Task $foundTask already exists. Returning.');
      return foundTask;
    }

    var result = Task(taskName, _user.id);
    log.info('Task $result doesn\'t exist. Adding.');

    _tasks.add(result);
    await database.insert(result);
    notifyListeners();

    return result;
  }

  // Filter tasks ignoring case.
  //
  // TODO: Return a future stream.
  List<Task> filterTasks(String query) {
    if (query.isEmpty) {
      return _tasks;
    } else {
      // Filter by name!
      return _tasks
          .where(
              (task) => task.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Find task.
  bool existsTask(String taskName) {
    return _tasks.contains(taskName);
  }
}
