use crate::connection::Connection;
use crate::error::Result;

/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
#[derive(Debug)]
pub struct User {
    /// The user id.
    pub id: i32,

    /// The name of this user.
    pub name: String,
}

impl User {
    /// Get the user given a name. This user must exist.
    async fn get(name: &str, connection: &Connection) -> Result<User> {
        let result = sqlx::query!(
            r#"
    SELECT id FROM users WHERE name=?
            "#,
            name
        )
        .fetch_one(connection.get_pool())
        .await?;

        let id = result
            .id
            .expect("Should exists since this field is NON NULL.");

        Ok(User {
            id,
            name: name.to_string(),
        })
    }

    /// Insert a user in the database
    pub async fn insert(name: &str, connection: &Connection) -> Result<User> {
        sqlx::query!(
            r#"
                INSERT INTO users ( name )
                VALUES ( ? )
            "#,
            name
        )
        .execute(connection.get_pool())
        .await?;

        User::get(name, connection).await
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
    async fn create_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let name = "Justin";
        let result = User::insert(name, &connection)
            .await
            .expect("Should successfully insert. ");

        assert_eq!(result.name, name);
    }

    #[tokio::test]
    async fn fail_if_already_exists() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let name = "DuplicateUser";
        let result = User::insert(name, &connection)
            .await
            .expect("Should successfully insert.");
        assert_eq!(result.name, name);

        let name = "DuplicateUser";
        let result = User::insert(name, &connection).await;

        assert_eq!(
            result.expect_err("Should have failed due to duplication"),
            crate::error::Error::AlreadyExists
        );
    }
}
