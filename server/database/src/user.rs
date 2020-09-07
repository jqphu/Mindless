use crate::connection::Connection;
use crate::error::{Error, Result};
use serde::{Deserialize, Serialize};
use sqlx::Done;

/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
///
/// We temporarily make this Serialize since we re-use this as the http rseponse. As the database
/// structure and the http query starts to diverge we will create a separate struct.
#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    /// The user id.
    id: i64,

    /// Username.
    username: String,

    /// Name
    name: String,
}

impl User {
    pub fn new(id: i64, username: String, name: String) -> User {
        User { id, username, name }
    }

    pub fn get_id(&self) -> i64 {
        self.id
    }

    /// Retrieve a user in the database by id.
    pub async fn retrieve(id: i64, connection: &Connection) -> Result<User> {
        let done = sqlx::query!(
            r#"
                SELECT username, name FROM users
                WHERE id = ( ? )
            "#,
            id
        )
        .fetch_one(connection.get_pool())
        .await?;

        Ok(User {
            id,
            username: done.username,
            name: done.name,
        })
    }

    /// Insert a user in the database
    pub async fn insert(username: &str, name: &str, connection: &Connection) -> Result<User> {
        sqlx::query!(
            r#"
                INSERT INTO users ( username, name )
                VALUES ( ?, ? )
            "#,
            username,
            name
        )
        .execute(connection.get_pool())
        .await?;

        User::get(username, connection).await
    }

    /// Delete a user from the database.
    ///
    /// This consumes self since it is invalid after deletion from the database.
    pub async fn delete(self, connection: &Connection) -> Result<()> {
        //  We really only need the id but we use everything to be specific.
        let deleted_row_count = sqlx::query!(
            r#"
                DELETE FROM users
                WHERE
                id = ( ? )
                AND
                username = ( ? )
                AND
                name = ( ? )
            "#,
            self.id,
            self.username,
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

    /// Set the username to a new value.
    ///
    /// This does not get comitted into the database until update is called.
    pub fn set_username(&mut self, username: String) {
        self.username = username;
    }

    pub async fn update(&mut self, connection: &Connection) -> Result<()> {
        sqlx::query!(
            r#"
                UPDATE users
                SET username = ( ? ),
                    name = ( ? )
                WHERE
                id = ( ? )
            "#,
            self.username,
            self.name,
            self.id
        )
        .execute(connection.get_pool())
        .await?;

        Ok(())
    }

    /// Get the user given a username. This user must exist.
    pub async fn get(username: &str, connection: &Connection) -> Result<User> {
        let result = sqlx::query!(
            r#"
    SELECT id, name FROM users WHERE username=?
            "#,
            username
        )
        .fetch_one(connection.get_pool())
        .await?;

        let id = result
            .id
            .expect("Should exists since this field is NON NULL.");

        let name = result.name;

        Ok(User::new(id, username.to_string(), name))
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

        let username = "justin_username";
        let name = "Justin";
        let result = User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert. ");

        assert_eq!(result.username, username);
        assert_eq!(result.name, name);
    }

    #[tokio::test]
    async fn fail_if_already_exists() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let username = "duplicate_username";
        let name = "DuplicateUser";
        let result = User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert.");
        assert_eq!(result.username, username);
        assert_eq!(result.name, name);

        let result = User::insert(username, name, &connection).await;

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

        let username = "JustinUserName";
        let name = "Justin";
        let user = User::insert(username, name, &connection)
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
            name: "justin".to_string(),
            username: "hello".to_string(),
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

        let username = "Justin";
        let name = "name";
        let mut user = User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert. ");
        assert_eq!(user.username, username);
        assert_eq!(user.name, name);

        let new_username = "James";
        let new_name = "Foo";
        user.set_username(new_username.to_string());
        user.set_name(new_name.to_string());

        user.update(&connection)
            .await
            .expect("Update should succeed.");

        // Let's try extract the updated user.
        let new_user = User::retrieve(user.id, &connection)
            .await
            .expect("User should exist.");
        assert_eq!(new_user.username, new_username);
        assert_eq!(new_user.name, new_name);

        // Can insert original user again.
        User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert since username has changed.");
    }

    #[tokio::test]
    async fn retrieve_user() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let username = "Justin";
        let name = "name";
        let result = User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert. ");
        assert_eq!(result.username, username);
        assert_eq!(result.name, name);

        let id = result.id;

        let user = User::retrieve(id, &connection)
            .await
            .expect("Should be able to retrieve just inserted user.");
        assert_eq!(user.username, username);
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
