use anyhow::Result;
use sqlx::pool::PoolConnection;
/// This is a file that implements building blocks to query the sql database. It is made to keep the logic from querying the database separate form the business logic
use sqlx::SqliteConnection;

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
    /// This will create the habit if it does not exist.
    pub async fn mark_habit(&mut self) -> Result<()> {
        let id = match self.get_id().await? {
            Some(id) => id,
            None => self.create_habit().await?,
        };

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
