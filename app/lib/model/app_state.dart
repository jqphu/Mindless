import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';

import 'dart:async';

import 'database_repository.dart';
import 'user.dart';
import 'task.dart';

final log = Logger('AppState');

class AppStateModel extends ChangeNotifier {
  /// The SQLite database.
  TaskDatabase database = TaskDatabase();

  /// User that is logged in. The user never is cleared.
  late User _user;

  /// List of tasks.
  List<Task> _tasks = [];

  /// Current task.
  Task? _currentTask;

  /// Initialize the AppStateModel with the user.
  AppStateModel() {
    reset();
    Timer.periodic(Duration(seconds: 1), (Timer t) async {
      if (_currentTask != null) {
        _currentTask!.addDuration(Duration(seconds: 1));
        notifyListeners();
      }
    });
  }

  String get username => _user.username;
  String get name => _user.name;
  Task? get currentTask => _currentTask;

  // Reset AppStateModel
  void reset() {
    _tasks = [];
    _currentTask = null;
  }

  void loadUser(User user) async {
    // TODO: Initialize different DB for each user.

    log.finer('Loading user $user');
    _user = user;
    _tasks = await database.initialize(user);
    // Bypass setCurrentTask since we're just continuing.
    _currentTask = _user.currentTask;

    notifyListeners();
  }

  void setCurrentTask(Task? task) async {
    log.finer('Starting current task $task current is ${_user.currentTask}');

    // Update current task state.
    if (_currentTask != null) {
      var instance = _currentTask!.end();
      await database.updateInstance(instance);
    }

    if (task != null) {
      var instance = task.start();

      await database.insertInstance(instance);
    }

    // Update the user to the new task.
    _user.currentTask = task;
    _currentTask = task;

    await database.updateUser(_user);

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
      _currentTask = null;
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
    var foundTask =
        _tasks.singleWhereOrNull((Task task) => task.name == taskName);
    if (foundTask != null) {
      log.info('Task $foundTask already exists. Returning.');
      return foundTask;
    }

    var result = Task(taskName, _user.id!);
    log.info('Task $result doesn\'t exist. Adding.');

    _tasks.add(result);
    await database.insert(result);

    setCurrentTask(result);

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
