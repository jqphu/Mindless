import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import 'package:mindless/model/user.dart';

import 'task.dart';

final log = Logger('login');

// Create a database per user.
const kDatabaseName = 'database.db';

const kTableTasks = 'tasks';
const kTableUsers = 'users';

class TaskDatabase {
  Database db;

  /// Initialize Database.
  Future<User> initialize(User user) async {
    log.info('Initializing database!');
    db = await openDatabase(
      join(await getDatabasesPath(), kDatabaseName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute('''
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER NOT NULL PRIMARY KEY,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  -- Name of this task.
  name TEXT NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(parent_id) REFERENCES tasks(id),

  -- Ensure the task and username pair is unique.
  CONSTRAINT unique_task_username UNIQUE(user_id, name)
);
''');

        await db.execute(
          '''
CREATE TABLE IF NOT EXISTS users (
  id INTEGER NOT NULL PRIMARY KEY,

  -- Username
  username TEXT NOT NULL,

  -- The name of the user.
  name TEXT NOT NULL,

  -- Current task id. May be NULL.
  current_task_id INTEGER,

  FOREIGN KEY(current_task_id) REFERENCES tasks(id),

  -- Ensure the usernames are unique.
  CONSTRAINT unique_username UNIQUE(username)
);
''',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    await db
        .insert(
      kTableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    )
        .then((int id) {
      user.id = id;
    });

    // Must always exit.
    Map user_map = (await db.query(kTableUsers,
        columns: ['id', 'username', 'name', 'current_task_id'],
        where: 'username = ?',
        whereArgs: [user.username],
        limit: 1))[0];

    var current_task;
    if (user_map['current_task_id'] != null) {
      Map task_map = (await db.query(kTableTasks,
          columns: ['id', 'user_id', 'name'],
          where: 'id = ?',
          whereArgs: [user_map['current_task_id']],
          limit: 1))[0];

      current_task = Task.fromMap(task_map);
    }

    return User(
        user_map['username'], user_map['name'], user_map['id'], current_task);
  }

  Future<void> updateUser(User user) async {
    log.finer('Update user to $user');

    var count = await db.update(kTableUsers, user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
    assert(count == 1);
  }

  /// Get the tasks from the database.
  Future<List<Task>> loadTasks(int id) async {
    assert(db != null);

    List<Map> maps = await db.query(kTableTasks,
        columns: ['id', 'user_id', 'name'],
        where: 'user_id = ?',
        whereArgs: [id]);

    return maps.map((Map map) => Task.fromMap(map)).toList();
  }

  Future<void> update(Task task) async {
    log.finer('Updating task $task');
    var count = await db.update(kTableTasks, task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
    assert(count == 1);
  }

  /// Delete a task.
  Future<void> delete(Task task) async {
    log.fine('Deleting task $task');
    var count =
        await db.delete(kTableTasks, where: 'id = ?', whereArgs: [task.id]);
    assert(count == 1);
  }

  /// Insert a task.
  Future<Task> insert(Task task) async {
    log.fine('Inserting task $task');
    task.id = await db.insert(kTableTasks, task.toMap());
    return task;
  }

  Future<void> saveTasks(List<Task> tasks) async {
    log.fine('Saving all tasks.');
    await tasks.forEach((task) async {
      await insert(task).catchError((error) {
        log.fine('Failed to add $task with error $error.');
      });
    });
  }
}
