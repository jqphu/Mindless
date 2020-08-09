use crate::error::Result;
use sqlx::SqlitePool;

/// A simple database abstraction which contains the db info.
///
/// This will simply contain the connection but hides what kind
/// of connection it is from the user.
///
/// We use this as a dependency injection as opposed to using a global static.
pub struct Connection {
    pool: SqlitePool,
}

impl Connection {
    /// Connect to a Sqlite3 database.
    ///
    /// # Arguments
    ///
    /// * `sqlite3_db_uri` - A sqlite3 datbase uri.
    ///
    /// # Examples
    /// ```
    /// #[tokio::main]
    /// # async fn main() {
    ///     let database = database::connection::Connection::connect("sqlite::memory:").await;
    /// #   assert!(database.is_ok(), "Should be able to connect to the in memory database.");
    /// # }
    /// ```
    pub async fn connect(sqlite3_db_uri: &str) -> Result<Self> {
        Ok(Connection {
            pool: SqlitePool::new(sqlite3_db_uri).await?,
        })
    }

    /// Acquire a single connection to the database.
    pub fn get_pool(&self) -> &SqlitePool {
        &self.pool
    }

    /// Connect to an in memory database also loading the schema.
    #[cfg(test)]
    pub async fn connect_temporary_with_schema() -> Result<Self> {
        let pool = Connection::connect("sqlite::").await?;
        let connection = pool.acquire().await?;

        sqlx::query_file!("data/mindless.sql")
            .execute(connection)
            .await?;

        Ok(pool)
    }
}
