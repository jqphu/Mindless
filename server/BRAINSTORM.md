# Habit structure

## User facing capabilities
* Create a user:
  * Basic user information, simply a name / hashed email will do

* Create a habit with:
  * Name - Hierarchical Style
    * E.g. Health/Exercise/Gym/Squat, Health/Food/LowCarb etc
  * User
  * Frequency
    * Daily, weekly, hourly etc
  * Notes
    * Any additional information
  * Counter (times we've hit / missed the habit)

* Mark a habit as completed
  * Should not mark again if it already done
  * Should be able to mark habits in the past

* Unmarking a habit
  * Habit was undone/not complete
  * Should be able to unmark habits in the past

* Delete a habit
  * Should be able to delete a whole tree of habits

graph view:
https://dbdiagram.io/d/5f28b8a37543d301bf5dbfb8
```rust
// Simple user.
Table users {
  id int [pk, increment]
  full_name varcharacter
  email varcharacter
}

// A single habit.
// E.g. Gym, Run, Study
Table habit {
  id int [pk, increment]
  // The parent habit in the heirarchy.
  // E.g. if this habit is "Exercise" the parent may be "Health"
  parent_id int
  user_id int [not null, unique]
  created_at datetime [default: `now()`]
  // Period (in seconds) at which the habit gets automatically unmarked.
  // E.g. Daily habit this value will be 24 hours.
  repeat_period unsigned [not null]

  // MISC notes.
  notes varcharacter
}

Ref: habit.user_id > users.id
Ref: habit.parent_id > habit.id

// A habit that has been marked.
Table habit_instance {
  id int [pk, increment]
  habit_id int [not null, unique]
  created_at datetime [default: `now()`]
  
  // Target time until this habit is marked as completed.
  target_duration unsigned
  
  // Whether this habit has been completed in this period.
  completed bool
}

Ref: habit_instance.habit_id > habit.id

/// The time spent on this habit.
Table elapsed_period {
  id int [pk, increment]
  habit_instance_id int [not null, unique]
  
  // Started time.
  started_at datetime [default: `now()`]
  ended_at datetime
}

Ref: elapsed_period.habit_instance_id > habit_instance.id
```

# Server API Structure

## Create a user

mod User {
```rust
  enum Request {
    Create(name: String),
    Delete(id: u64)
  };

  enum Response {
    AlreadyExists,
    NotFound,
    Success(user_id: u64)
  };

}
```

## Create a habit

* What does the user interface for creating a tree of habits look like.

* E.g. I want to create "Health/Exercise/Gym/Squat"

/// Duration in seconds.
struct Duration(i64)

mod Habit {

  enum Request {
    Create(
      user_id: u64,
      /// Parent of this habit.
      /// If this is optional this is a root habit.
      parent_id: Option<u64>,

      /// Habit name.
      name: String, 

      /// Repeat Period. How often to repeat this habit.
      repeat_period: u64,
    ),

    Delete(id: u64),

    /// Update the notes about this instance. This will override the notes.
    UpdateNotes(id: u64, notes: String)
  }

  enum Response {
    AlreadyExists,
    NotFound,
    Success(habit_id: u64)
  }

}

mod Instance {

  enum Request {
    /// Create an instance of this habit.
    Create(habit_id: u64),

    /// Delete this habit instance.
    Delete(id: u64),

    /// Update the notes about this habit. This will override the notes.
    UpdateNotes(id: u64, notes: String)
  }

  enum Response {
    AlreadyExists,
    NotFound,
    Success(instance_id: u64)
  }

}

mod ElapsedPeriod {

  enum Request {
    /// Track that we spend this much time on a habit.
    /// This may transition the instance to completed state.
    Create(instance_id: u64, start_utc_seconds: u64, end_utc_seconds: u64),

    /// Start tracking time for this habit.
    Start(instance_id: u64),

    /// Pause time tracking time for this habit.
    Pause(id: u64),

    /// Continue time tracking time for this habit.
    Resume(id: u64),

    /// Stop tracking time for this habit.
    End(id: u64)

    /// Update the notes about this elapsed period. This will override the notes.
    UpdateNotes(id: u64, notes: String)
  }

  enum Response {
    AlreadyExists,
    NotFound,
    InvalidState,
    Success(elapsed_period_id: u64),
  }
}
