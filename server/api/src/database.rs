/// This is the database interface to habits.
///
/// Ideally, all SQL errors and logic as swallowed at this level and they don't get seen further
/// up.
///
/// We almost always create the ID if it doesn't exist since there is no downside in doing this.
use anyhow::Result;
use sqlx::pool::PoolConnection;

/// This is a file that implements building blocks to query the sql database.
/// It is made to keep the logic from querying the database separate form the business logic
use sqlx::SqliteConnection;

use chrono::prelude::*;

/// This is a struct representing a habit that is connected to a database.
///
/// It abstracts the sql queries away.
pub struct Habit {
    /// The sqlite connection. We keep this alive for as long as this Habit is alive.
    pub connection: PoolConnection<SqliteConnection>,

    /// The name of this habit.
    pub name: String,
}

impl Habit {
    /// Create a habit in the database.
    ///
    /// This will return an error if the habit already exists.
    /// TODO: We likely don't know the state of the DB. Something else could have modified it.
    /// Instead of create and returning an error, let's just be safe and get_id_or_create. Fix this
    /// naming.
    pub async fn create_habit(&mut self) -> Result<i32> {
        // We explicitly use the '?' operator to allow a conversion to an anyhow error.
        sqlx::query!(
            r#"
INSERT INTO habit_log ( habit_name )
VALUES ( ? )
        "#,
            &self.name
        )
        .execute(&mut self.connection)
        .await?;

        // TODO: Use an SQL query to get the last row instead.
        let id = self.get_id().await?;

        Ok(id.expect("ID must exist since we just inserted it"))
    }

    /// Mark a habit as completed.
    ///
    /// This will be a no-op if the habit is already set today.
    ///
    /// This will create the habit if it does not exist.
    pub async fn mark_habit(&mut self) -> Result<()> {
        let id = self.get_id_or_create().await?;
        if self.is_set_today().await? {
            return Ok(());
        }

        println!("Marking a habit today!");

        // We explicitly use the '?' operator to allow a conversion to an anyhow error.
        sqlx::query!(
            r#"
        INSERT INTO habit ( habit_id )
        VALUES ( ? )
            "#,
            id
        )
        .execute(&mut self.connection)
        .await?;

        Ok(())
    }

    /// Check if a habit is set.
    ///
    /// This will create the habit if it does not exist.
    async fn is_set_today(&mut self) -> Result<bool> {
        let id = self.get_id_or_create().await?;

        // We explicitly use the '?' operator to allow a conversion to an anyhow error.
        // TODO: For some reason we get a `MAX(completed_time)` is not a valid Rust identifier when
        // we have the select statement by itself.
        let fetched_result = sqlx::query!(
            r#"
            SELECT completed_time
            FROM habit
            WHERE completed_time=
            (SELECT MAX(completed_time) FROM habit WHERE habit_id = ( ? ))"#,
            id,
        )
        .fetch_one(&mut self.connection)
        .await;

        let last_set_utc_time = match fetched_result {
            Ok(result) => result.completed_time,
            // Couldn't find a completed_time means this habit has never been set.
            // Return early.
            Err(sqlx::Error::RowNotFound) => return Ok(false),
            Err(e) => return Err(anyhow::Error::new(e)),
        };

        // TODO: Enforce a certain timezone in the likely case the server is elsewhere...
        let last_set_date_time =
            Local.from_utc_datetime(&NaiveDateTime::from_timestamp(last_set_utc_time.into(), 0));
        let current_date_time = Local::now();

        let duration_difference = current_date_time.signed_duration_since(last_set_date_time);

        println!(
            "Last set time was {:?} and now is {:?} with difference {:?}",
            last_set_date_time, current_date_time, duration_difference
        );

        // Already been set!
        Ok(duration_difference.num_days() == 0)
    }

    /// Get the id of this habit. If one isn't found, it will create one.
    ///
    /// On success this returns the habit id.
    async fn get_id_or_create(&mut self) -> Result<i32> {
        let id = match self.get_id().await? {
            Some(id) => id,
            None => self.create_habit().await?,
        };

        return Ok(id);
    }

    /// Get the id of this habit.
    ///
    /// On success this returns the habit id.
    /// On not found this returns None.
    /// On other error this returns the error.
    async fn get_id(&mut self) -> Result<Option<i32>> {
        let fetched_result = sqlx::query!(
            r#"
    SELECT id FROM habit_log WHERE habit_name=?
            "#,
            &self.name
        )
        .fetch_one(&mut self.connection)
        .await;

        match fetched_result {
            // Value was found.
            Ok(fetched_value) => Ok(fetched_value.id),

            // Value was not found.
            Err(sqlx::Error::RowNotFound) => Ok(None),

            // Unknown error.
            Err(e) => Err(anyhow::Error::new(e)),
        }
    }
}
