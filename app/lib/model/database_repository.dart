import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import 'package:mindless/model/user.dart';
import 'package:mindless/model/instance.dart';

import 'task.dart';

final log = Logger('data_repository');

// Create a database per user.
const kDatabaseName = 'database.db';

const kTableTasks = 'tasks';
const kTableInstances = 'instances';
const kTableUsers = 'users';

class TaskDatabase {
  late Database db;

  /// Initialize Database.
  Future<List<Task>> initialize(User user) async {
    log.info('Initializing database!');
    // await deleteDatabase(join(await getDatabasesPath(), kDatabaseName));
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

  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(parent_id) REFERENCES tasks(id),

  -- Ensure the task and username pair is unique.
  CONSTRAINT unique_task_username UNIQUE(user_id, name)
);
''');

        await db.execute('''
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
''');

        await db.execute('''
  CREATE TABLE IF NOT EXISTS instances (
  id INTEGER NOT NULL PRIMARY KEY,

  -- Which instance this period belongs to.
  task_id INTEGER NOT NULL,

  -- The time this period started from epoch in milliseoncs.
  started_at INTEGER,

  -- Time spent on this instance.
  time_spent INTEGER NOT NULL,

  -- DElete all instances if task is deleted
  FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
  );
  ''');
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

    var userId = user_map['id'];
    user.id = userId;

    var currentTaskId = user_map['current_task_id'];

    // Load all the tasks and instances.
    var tasks = await _loadTasks(userId);

    if (currentTaskId != null) {
      // Must exist, since there is a currentTaskId.
      user.currentTask = tasks.firstWhere((task) => task.id == currentTaskId);
    }

    return tasks;
  }

  Future<void> updateUser(User user) async {
    log.finer('Update user to $user');

    var count = await db.update(kTableUsers, user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
    assert(count == 1);
  }

  /// Get the tasks from the database.
  Future<List<Task>> _loadTasks(int id) async {
    /// TODO: Make this a inner join...
    var maps = await db.query(kTableTasks,
        columns: ['id', 'user_id', 'name'],
        where: 'user_id = ?',
        whereArgs: [id]);

    var tasks = maps
        .map((Map map) => Task.fromMap(map as Map<String, Object?>))
        .toList();

    log.finer('Loaded $tasks');

    for (var task in tasks) {
      log.finer('Loading $task');
      var instancesMap = await db.query(kTableInstances,
          columns: ['id', 'started_at', 'time_spent'],
          where: 'task_id = ?',
          whereArgs: [task.id]);

      // Assume it goes from smallest id first.
      var instances = instancesMap.map((Map<String, Object?> map) {
        return Instance.fromMap(map, task);
      }).toList();
      log.finer('Instances $instances');

      task.addInstances(instances);
    }

    return tasks;
  }

  Future<void> update(Task task) async {
    log.finer('Updating task $task');
    var count = await db.update(kTableTasks, task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
    assert(count == 1);
  }

  Future<void> updateInstance(Instance instance) async {
    log.fine('Updating instance $instance');
    var count = await db.update(kTableInstances, instance.toMap(),
        where: 'id = ?', whereArgs: [instance.id]);
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
    assert(task.id != 0);
    return task;
  }

  Future<void> insertInstance(Instance instance) async {
    log.fine('Inserting instance $instance');
    instance.id = await db.insert(kTableInstances, instance.toMap());
  }

  Future<void> saveTasks(List<Task> tasks) async {
    log.fine('Saving all tasks.');
    tasks.forEach((task) async {
      await insert(task).catchError((error) {
        log.fine('Failed to add $task with error $error.');
      });
    });
  }
}
