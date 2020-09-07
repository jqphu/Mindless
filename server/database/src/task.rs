use crate::connection::Connection;
use crate::error::{Error, Result};
use crate::user::User;
use serde::{Deserialize, Serialize};
use sqlx::Done;
use sqlx::FromRow;
use std::cmp::PartialEq;

use crate::SqlId;

/// This is a struct representing a task.
///
/// It abstracts the sql queries away.
///
/// We temporarily make this Serialize since we re-use this as the http rseponse. As the database
/// structure and the http query starts to diverge we will create a separate struct.
#[derive(Debug, FromRow, Serialize, Deserialize, PartialEq)]
pub struct Task {
    /// The task id.
    id: SqlId,

    /// User Id.
    user_id: SqlId,

    /// Name.
    name: String,
}

impl Task {
    pub fn new(id: SqlId, user_id: SqlId, name: String) -> Task {
        Task { id, user_id, name }
    }

    pub fn get_id(&self) -> SqlId {
        self.id
    }

    /// Retrieve a task in the database by id.
    pub async fn retrieve(id: i64, connection: &Connection) -> Result<Task> {
        let task = sqlx::query_as!(
            Task,
            r#"
                SELECT id, user_id, name FROM tasks
                WHERE id = ( ? )
            "#,
            id
        )
        .fetch_one(connection.get_pool())
        .await?;

        Ok(task)
    }

    /// Find a task in the database by id.
    pub async fn find(&mut self, connection: &Connection) -> Result<()> {
        let task = sqlx::query_as!(
            Task,
            r#"
                SELECT id, user_id, name FROM tasks
                WHERE
                user_id = ( ? )
                AND
                name = ( ? )
            "#,
            self.user_id,
            self.name
        )
        .fetch_one(connection.get_pool())
        .await?;

        self.id = task.id;

        Ok(())
    }

    /// Insert a task into the database
    pub async fn insert(&mut self, connection: &Connection) -> Result<()> {
        let result = sqlx::query!(
            r#"
                INSERT INTO tasks ( user_id, name )
                VALUES ( ?, ? )
            "#,
            self.user_id,
            self.name
        )
        .execute(connection.get_pool())
        .await?;

        let last_rowid = result.last_insert_rowid();

        let task_result = sqlx::query_as!(
            Task,
            r#"
                SELECT id, user_id, name
                FROM tasks
                WHERE rowid= ( ? )
            "#,
            last_rowid
        )
        .fetch_one(connection.get_pool())
        .await?;

        self.id = task_result.id;

        Ok(())
    }

    /// Try Insert a task into the database
    pub async fn try_insert(&mut self, connection: &Connection) -> Result<()> {
        // TODO: Match on the error sepcifically.
        // If this fails with already found, ignore and proceed.
        let _result = sqlx::query!(
            r#"
                INSERT INTO tasks ( user_id, name )
                VALUES ( ?, ? )
            "#,
            self.user_id,
            self.name
        )
        .execute(connection.get_pool())
        .await;

        self.find(connection).await?;

        Ok(())
    }

    /// Insert a vector of tasks
    pub async fn try_insert_all(tasks: &mut Vec<Task>, connection: &Connection) -> Result<()> {
        for task in tasks.iter_mut() {
            task.try_insert(connection).await?;
        }

        Ok(())
    }

    /// Delete a user from the database.
    ///
    /// This consumes self since it is invalid after deletion from the database.
    pub async fn delete(self, connection: &Connection) -> Result<()> {
        //  We really only need the id but we use everything to be specific.
        let deleted_row_count = sqlx::query!(
            r#"
                DELETE FROM tasks
                WHERE
                id = ( ? )
                AND
                user_id = ( ? )
                AND
                name = ( ? )
            "#,
            self.id,
            self.user_id,
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

    /// Get all tasks for a user.
    pub async fn get_tasks(user: &User, connection: &Connection) -> Result<Vec<Task>> {
        let user_id = user.get_id();

        let tasks = sqlx::query_as!(
            Task,
            r#"
                SELECT id, user_id, name FROM tasks
                WHERE user_id = ( ? )
            "#,
            user_id
        )
        .fetch_all(connection.get_pool())
        .await?;

        Ok(tasks)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    static USERNAME: &str = "test_username";
    static NAME: &str = "test_name";

    static TASK_NAME: &str = "Exercise";

    async fn create_test_user(username: &str, name: &str, connection: &Connection) -> User {
        User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert. ")
    }

    #[tokio::test]
    async fn insert_task() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let user = create_test_user(USERNAME, NAME, &connection).await;

        let task = Task::insert(user.get_id(), TASK_NAME, &connection)
            .await
            .expect("Should successfully insert.");

        assert_eq!(task.name, TASK_NAME);
        assert_eq!(task.user_id, user.get_id());
    }

    #[tokio::test]
    async fn delete_task() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let user = create_test_user(USERNAME, NAME, &connection).await;

        let task = Task::insert(user.get_id(), TASK_NAME, &connection)
            .await
            .expect("Should successfully insert.");

        task.delete(&connection)
            .await
            .expect("Should be able to remove task.");
    }

    #[tokio::test]
    async fn get_tasks() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let user = create_test_user(USERNAME, NAME, &connection).await;

        let task1 = Task::insert(user.get_id(), TASK_NAME, &connection)
            .await
            .expect("Should successfully insert.");

        let task2 = Task::insert(user.get_id(), "second_task", &connection)
            .await
            .expect("Should successfully insert.");

        let tasks = Task::get_tasks(&user, &connection)
            .await
            .expect("Should get all tasks.");

        assert_eq!(tasks.len(), 2);
        assert_eq!(tasks[0], task1);
        assert_eq!(tasks[1], task2);
    }
}
