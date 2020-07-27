-- List of users!
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,

  -- The name of the habit as a string.
  username TEXT NOT NULL,

  -- Unique username.
  CONSTRAINT unique_username UNIQUE (username)
);

-- List of habits!
CREATE TABLE IF NOT EXISTS habit_log (
  id INTEGER PRIMARY KEY,

  -- The user this habit belongs to.
  user_id INTEGER NOT NULL,

  -- The name of the habit as a string.
  habit_name TEXT NOT NULL,

  -- Each user must have unique habits.
  CONSTRAINT unique_user_habit_pair UNIQUE (user_id, habit_name)
);

-- A habit instance
CREATE TABLE IF NOT EXISTS habit (
  id INTEGER PRIMARY KEY,
  -- References a habit type.
  habit_id INTEGER NOT NULL,
  -- The timestamp the habit was set.
  -- The time is seconds since 1970-01-01 UTC
  completed_time INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  -- Unique habit_id and completed_time combo. This should be checked in software but
  -- as a defensive measure we add the constraint in the database.
  CONSTRAINT unique_habit_id_time_pair UNIQUE(habit_id, completed_time),
  -- when parent deletes, delete ourself
  CONSTRAINT foriegn_key_habits FOREIGN KEY (habit_id) REFERENCES habit_log(id) -- when parent is updated, update child (not sure how this would work)
  ON DELETE CASCADE ON UPDATE CASCADE
);

-- SELECT * FROM habit INNER JOIN habit_log ON habit.habit_id=habit_log.id;
-- to visualise the joined data.
