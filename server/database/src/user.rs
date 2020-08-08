use crate::connection::Connection;
use crate::error::Result;

use sqlx::pool::PoolConnection;
use sqlx::SqliteConnection;

/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
pub struct User {
    /// The user id.
    pub id: i32,

    /// The name of this user.
    pub name: String,
}

impl User {
    /// Get the id given a name.
    async fn get_id(name: &str, connection: &mut PoolConnection<SqliteConnection>) -> Result<i32> {
        let result = sqlx::query!(
            r#"
    SELECT id FROM users WHERE name=?
            "#,
            name
        )
        .fetch_one(connection)
        .await?;

        Ok(result
            .id
            .expect("Should exists since this field is NON NULL."))
    }

    /// Insert a user in the database
    pub async fn insert(name: &str, pool: &Connection) -> Result<User> {
        let mut connection = pool.acquire().await?;

        sqlx::query!(
            r#"
                INSERT INTO users ( name )
                VALUES ( ? )
            "#,
            name
        )
        .execute(&mut connection)
        .await?;

        let user_id = User::get_id(name, &mut connection).await?;

        Ok(User {
            id: user_id,
            name: name.to_string(),
        })
    }

    /// Create a new connection to the database representing a user.
    ///
    /// # Examples
    ///
    /// ```
    /// let user = database::user::User::new("Justin".to_string());
    /// ```
    pub async fn new(name: String) -> Self {
        User { id: 0, name }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn can_create_user() {
        let db_url = std::env::var("DATABASE_URL").expect("Should have a Database URL env set.");
        let connection = Connection::connect(&db_url).await.expect("Should connect");
        let name = "Justin";
        let result = User::insert(name, &connection)
            .await
            .expect("Should successfully insert. ");

        assert_eq!(result.name, name);
    }
}
