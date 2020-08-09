use crate::connection::Connection;
use crate::error::{Error, Result};
use serde::Serialize;
use sqlx::Done;

/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
///
/// We temporarily make this Serialize since we re-use this as the http rseponse. As the database
/// structure and the http query starts to diverge we will create a separate struct.
#[derive(Debug, Serialize)]
pub struct User {
    /// The user id.
    id: i64,

    /// The name of this user.
    name: String,
}

impl User {
    pub fn new(id: i64, name: String) -> User {
        User { id, name }
    }
    /// Retrieve a user in the database by id.
    pub async fn retrieve(id: i64, connection: &Connection) -> Result<User> {
        let done = sqlx::query!(
            r#"
                SELECT name FROM users
                WHERE id = ( ? )
            "#,
            id
        )
        .fetch_one(connection.get_pool())
        .await?;

        Ok(User {
            id,
            name: done.name,
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

        if deleted_row_count.rows_affected() == 0 {
            Err(Error::NotFound)
        } else {
            Ok(())
        }
    }

    /// Set the name to a new value.
    ///
    /// This does not get comitted into the database until update is called.
    pub fn set_name(&mut self, name: String) {
        self.name = name;
    }

    pub async fn update(&mut self, connection: &Connection) -> Result<()> {
        sqlx::query!(
            r#"
                UPDATE users
                SET name = ( ? )
                WHERE
                id = ( ? )
            "#,
            self.name,
            self.id
        )
        .execute(connection.get_pool())
        .await?;

        Ok(())
    }

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
            result.expect_err("Should have failed due to duplication."),
            crate::error::Error::AlreadyExists
        );
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
    }

    #[tokio::test]
    async fn fail_delete_non_existent_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let user = User {
            id: 123,
            name: "hello".to_string(),
        };

        let result = user.delete(&connection).await;

        assert_eq!(
            result.expect_err("Should fail due to not existing."),
            crate::error::Error::NotFound
        );
    }

    #[tokio::test]
    async fn update_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let name = "Justin";
        let mut user = User::insert(name, &connection)
            .await
            .expect("Should successfully insert. ");
        assert_eq!(user.name, name);

        user.set_name("James".to_string());

        user.update(&connection)
            .await
            .expect("Update should succeed.");

        // Can insert original user again.
        User::insert(name, &connection)
            .await
            .expect("Should successfully insert since name has changed.");
    }

    #[tokio::test]
    async fn retrieve_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let name = "Justin";
        let result = User::insert(name, &connection)
            .await
            .expect("Should successfully insert. ");
        assert_eq!(result.name, name);

        let id = result.id;

        let user = User::retrieve(id, &connection)
            .await
            .expect("Should be able to retrieve just inserted user.");
        assert_eq!(user.name, name);
    }

    #[tokio::test]
    async fn fail_to_retrieve_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let result = User::retrieve(123584, &connection).await;
        assert_eq!(
            result.expect_err("Should not be able to retrieve invalid id"),
            crate::error::Error::NotFound
        );
    }
}
