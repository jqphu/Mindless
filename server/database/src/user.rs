use crate::connection::Connection;
use crate::error::{Error, Result};

/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
#[derive(Debug)]
pub struct User {
    /// The user id.
    id: i32,

    /// The name of this user.
    name: String,
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

    /// Delete a user from the database.
    ///
    /// This consumes self since it is invalid after deletion from the database.
    pub async fn delete(self, connection: &Connection) -> Result<()> {
        // We don't have to use both identifiers but we do anyway for safety.
        let deleted_row_count = sqlx::query!(
            r#"
                DELETE FROM users
                WHERE
                id = ( ? )
                AND
                name = ( ? )
            "#,
            self.id,
            self.name
        )
        .execute(connection.get_pool())
        .await?;

        if deleted_row_count == 0 {
            Err(Error::NotFound)
        } else {
            Ok(())
        }
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
    async fn delete_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let name = "Justin";
        let user = User::insert(&name, &connection)
            .await
            .expect("Should successfully insert. ");

        user.delete(&connection)
            .await
            .expect("Can delete newly added user.");

        User::insert(&name, &connection)
            .await
            .expect("Can add the user again.");
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
