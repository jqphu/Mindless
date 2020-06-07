-- Insert 3 habits
INSERT INTO
  habit_log (habit_name)
VALUES
  ('Exercise'),
  ('Cold Shower'),
  ('Wakeup');
--- Insert some data into Wakeup
INSERT INTO
  habit (habit_id, completed_time)
VALUES
  --- 2020-05-31 04:32:00 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    ),
    strftime(
      '%s',
      datetime('2020-05-31 04:00:00', '-10 hours')
    )
  ),
  --- 2020-05-30 04:12:00 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    ),
    strftime(
      '%s',
      datetime('2020-05-30 04:12:00', '-10 hours')
    )
  ),
  --- 2020-05-27 03:52:02 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    ),
    strftime(
      '%s',
      datetime('2020-05-27 03:52:02', '-10 hours')
    )
  ),
  --- 2020-05-22 04:02:38 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Wakeup'
    ),
    strftime(
      '%s',
      datetime('2020-05-22 04:02:38', '-10 hours')
    )
  );
--- Insert some data into Exercise
INSERT INTO
  habit (habit_id, completed_time)
VALUES
  --- 2020-05-31 14:00:00 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Exercise'
    ),
    strftime(
      '%s',
      datetime('2020-05-31 14:00:00', '-10 hours')
    )
  ),
  --- 2020-05-29 14:32:11 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Exercise'
    ),
    strftime(
      '%s',
      datetime('2020-05-29 14:32:11', '-10 hours')
    )
  ),
  --- 2020-05-26 13:52:02 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Exercise'
    ),
    strftime(
      '%s',
      datetime('2020-05-26 13:52:02', '-10 hours')
    )
  );
--- Insert some data into Cold Shower
INSERT INTO
  habit (habit_id, completed_time)
VALUES
  --- 2020-05-31 04:22:00 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Cold Shower'
    ),
    strftime(
      '%s',
      datetime('2020-05-31 04:22:00', '-10 hours')
    )
  ),
  --- 2020-05-26 14:20:01 AEST
  (
    (
      SELECT
        id
      FROM
        habit_log
      WHERE
        habit_name = 'Cold Shower'
    ),
    strftime(
      '%s',
      datetime('2020-05-26 14:20:01', '-10 hours')
    )
  );
