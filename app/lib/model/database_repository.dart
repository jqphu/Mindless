import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'task.dart';

const kDatabaseName = 'database.db';

class TaskDatabase {
  Database database;

  int id;

  /// Initialize Database.
  void initialize(int user_id) async {
    id = user_id;

    database = await openDatabase(
      join(await getDatabasesPath(), kDatabaseName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  /// Get the tasks from the database.
  Future<List<Task>> loadTasks() async {
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
