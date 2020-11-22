import 'package:flutter/foundation.dart';
import 'task_respository.dart';
import 'user.dart';
import 'task.dart';

class AppStateModel extends ChangeNotifier {
  /// User that is logged in. The user never is cleared.
  final User _user;

  /// List of tasks.
  List<Task> _tasks;

  /// Initialize the AppStateModel with the user.
  AppStateModel(this._user) {
    assert(_user != null);
    _tasks = List();
  }

  String get username {
    return _user.username;
  }

  String get name {
    return _user.name;
  }

  // Loads the list of available products from the repo.
  void loadTasks() async {
    _tasks = await TasksRepository.loadTasks(_user.id);
    notifyListeners();
  }

  // Returns a copy of the list of the current tasks.
  List<Task> getTasks() {
    return _tasks;
  }
}
