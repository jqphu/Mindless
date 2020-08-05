-- List of users!
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,

  -- The name of the user.
  name TEXT NOT NULL,

  -- Ensure the usernames are unique.
  CONSTRAINT unique_username UNIQUE(name)
);

-- Representation of a habit
CREATE TABLE IF NOT EXISTS habit (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  -- Name of this habit.
  name TEXT NOT NULL,

  -- Time this habit was created.
  created_at DATETIME NOT NULL,

  -- Repeat period is in seconds.
  repeat_period_sec UNSIGNED,

  -- Optional set of notes.
  notes TEXT,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(parent_id) REFERENCES habit(id),

  -- Ensure the habit and username pair is unique.
  CONSTRAINT unique_habit_username UNIQUE(user_id, parent_id, name)
);

CREATE TABLE IF NOT EXISTS instance (
  id INTEGER PRIMARY KEY,
  habit_id INTEGER NOT NULL,

  -- Creation time.
  created_at datetime,

  -- The minimum amount of time to have been spent in this instance until we can mark it as complete.
  -- Note: This habit may be completed even if we don't achieve this time. This can happen when a user manually
  -- completes the habit.
  target_duration UNSIGNED,

  -- Whether or not this habit has been completed.
  completed BOOLEAN NOT NULL,

  -- Optional notes to add to this instance.
  notes TEXT,

  FOREIGN KEY(habit_id) REFERENCES habit(id)
);

-- The elapsed period represents time spent on a habit instance.
-- This elapsed period could be on-going and not ended yet.
-- You may have multiple elapsed periods for a single instance.
CREATE TABLE IF NOT EXISTS elapsed_period (
  id INTEGER PRIMARY KEY,

  -- Which instance this period belongs to.
  instance_id INTEGER NOT NULL,

  -- The time this period started.
  started_at datetime,

  -- The time this period completed.
  ended_at datetime,

  -- Optional notes to add to this instance.
  notes TEXT,

  FOREIGN KEY(instance_id) REFERENCES instance(id)
);

-- Example:
-- The habit is Exercise with the parent habit Health.
-- The repeat period is daily and it has multiple instances.
-- The target duration is 30 minutes.
-- The latest instance has an elapsed period that spans 20 minutes. Thus, it
-- is still yet to be completed.
