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
        await database.update(_currentTask);
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

    _user = user;

    database.initialize().whenComplete(() {
      // After logging in load the tasks.
      _loadTasks();

      notifyListeners();
    });
  }

  set currentTask(Task task) {
    _currentTask = task;

    notifyListeners();
  }

  // Loads the list of available products from the repo.
  void _loadTasks() async {
    _tasks = await database.loadTasks(_user.id);
    _currentTask = _tasks[2];
    notifyListeners();
  }

  void _saveTasks() async {
    await database.saveTasks(_tasks);
  }

  // Returns a copy of the list of the current tasks.
  List<Task> getTasks() {
    return _tasks;
  }

  // Delete a task
  //
  // Returns true if task was found and deleted, false when task wasn't found.
  Future<bool> deleteTask(Task task) async {
    if (task == currentTask) {
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
