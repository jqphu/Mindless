# [2020-06-07] 15:34

Continuing. Now I have a database connection let's add a habit.

Implementing a simple query to insert a habit:

```
INSERT INTO
  habit ( habit_id )
VALUES
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    )
  )
```

I assume it is faster if we do this as a single query as opposed to extracting the id and then
inserting a habit into a table. However, for simplicity let's separate this into two steps.

# [2020-05-31] 13:38

Let's add some trivial habits by string.

Requirements:
1. Set once a day only.
2. Set by some arbitrary string for now (no hierarchy)

SQL Schema:
To test the schema manually.
1. `sqlite3 habits.db`   - Open the database.
2. `.read schema.sql`    - Creates the tables.
3. `.read test_data.sql` - Read in the dummy data.
4. `SELECT * FROM habit INNER JOIN habit_log ON habit.habit_id=habit_log.id` - Visualise the joined
   data.

# [2020-05-30] 12:00

Another idea another repo another try. Tracker - QR code version.

