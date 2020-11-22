import 'task.dart';

class TasksRepository {
  /// Get the tasks from the database.
  static Future<List<Task>> loadTasks(userId) async {
    return Future.delayed(Duration(seconds: 1), () {
      return <Task>[
        Task('Sleep', 1, Duration(hours: 8, minutes: 32)),
        Task('Deep Work', 1, Duration(hours: 1, minutes: 07)),
        Task('Exercise', 1, Duration(hours: 0, minutes: 40)),
        Task('Mindless', 1, Duration(hours: 0, minutes: 00)),
        Task('A', 1, Duration(hours: 0, minutes: 0)),
        Task('B', 1, Duration(hours: 0, minutes: 0)),
        Task('C', 1, Duration(hours: 0, minutes: 0)),
        Task('D', 1, Duration(hours: 0, minutes: 0)),
        Task('E', 1, Duration(hours: 0, minutes: 0)),
        Task('F', 1, Duration(hours: 0, minutes: 0)),
        Task('G', 1, Duration(hours: 0, minutes: 0)),
        Task('H', 1, Duration(hours: 0, minutes: 0)),
        Task('I', 1, Duration(hours: 18, minutes: 32)),
      ];
    });
  }
}
