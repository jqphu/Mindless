use crate::connection::Connection;
use crate::error::{Error, Result};
use crate::SqlId;
use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use sqlx::Done;
use sqlx::FromRow;
use std::cmp::PartialEq;

/// This is a struct representing a task.
///
/// It abstracts the sql queries away.
///
/// We temporarily make this Serialize since we re-use this as the http rseponse. As the database
/// structure and the http query starts to diverge we will create a separate struct.
#[derive(Debug, FromRow, Serialize, Deserialize, PartialEq)]
pub struct Instance {
    /// Instance id.
    id: SqlId,

    /// Task Id.
    task_id: SqlId,

    /// Started Time.
    start: NaiveDateTime,

    /// End time.
    end: NaiveDateTime,
}

impl Instance {
    pub fn new(id: SqlId, task_id: SqlId, start: NaiveDateTime, end: NaiveDateTime) -> Instance {
        Instance {
            id,
            task_id,
            start,
            end,
        }
    }

    pub fn set_task_id(&mut self, task_id: SqlId) {
        self.task_id = task_id
    }

    /// Retrieve a instance in the database by id.
    pub async fn retrieve(id: i64, connection: &Connection) -> Result<Instance> {
        let instance = sqlx::query_as!(
            Instance,
            r#"
                SELECT id, task_id, start, end FROM instances
                WHERE id = ( ? )
            "#,
            id
        )
        .fetch_one(connection.get_pool())
        .await?;

        Ok(instance)
    }

    /// Find a instance in the database by id.
    pub async fn find(&mut self, connection: &Connection) -> Result<()> {
        let instance = sqlx::query_as!(
            Instance,
            r#"
                SELECT id, task_id, start, end FROM instances
                WHERE
                task_id = ( ? )
                AND
                start = ( ? )
                AND
                end = ( ? )
            "#,
            self.task_id,
            self.start,
            self.end
        )
        .fetch_one(connection.get_pool())
        .await?;

        self.id = instance.id;

        Ok(())
    }

    /// Insert a instance into the database
    pub async fn try_insert(&mut self, connection: &Connection) -> Result<()> {
        // TODO: Match on error only.
        // Ignore whether or not insert succeeded
        let _result = sqlx::query!(
            r#"
                INSERT INTO instances ( task_id, start, end )
                VALUES ( ?, ?, ? )
            "#,
            self.task_id,
            self.start,
            self.end
        )
        .execute(connection.get_pool())
        .await;

        self.find(connection).await
    }

    /// Insert a instance into the database
    pub async fn insert(
        task_id: SqlId,
        start: &NaiveDateTime,
        end: &NaiveDateTime,
        connection: &Connection,
    ) -> Result<Instance> {
        let result = sqlx::query!(
            r#"
                INSERT INTO instances ( task_id, start, end )
                VALUES ( ?, ?, ? )
            "#,
            task_id,
            start,
            end
        )
        .execute(connection.get_pool())
        .await?;

        let last_rowid = result.last_insert_rowid();

        let instance_result = sqlx::query_as!(
            Instance,
            r#"
                    SELECT id, task_id, start, end
                    FROM instances
                    WHERE rowid= ( ? )
                "#,
            last_rowid
        )
        .fetch_one(connection.get_pool())
        .await?;

        Ok(instance_result)
    }

    /// Insert a vector of instances
    pub async fn try_insert_all(
        mut instances: Vec<Instance>,
        connection: &Connection,
    ) -> Result<Vec<Instance>> {
        for instance in &mut instances {
            instance.try_insert(&connection).await?;
        }

        Ok(instances)
    }

    /// Delete a instance from the database.
    ///
    /// This consumes self since it is invalid after deletion from the database.
    pub async fn delete(self, connection: &Connection) -> Result<()> {
        //  We really only need the id but we use everything to be specific.
        let deleted_row_count = sqlx::query!(
            r#"
                   DELETE FROM instances
                   WHERE
                   id = ( ? )
                   AND
                   task_id = ( ? )
                   AND
                   start = ( ? )
                   AND
                   end = ( ? )
               "#,
            self.id,
            self.task_id,
            self.start,
            self.end
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
    pub async fn get_instances(task_id: SqlId, connection: &Connection) -> Result<Vec<Instance>> {
        let instances = sqlx::query_as!(
            Instance,
            r#"
                 SELECT id, task_id, start, end FROM instances
                 WHERE task_id = ( ? )
             "#,
            task_id
        )
        .fetch_all(connection.get_pool())
        .await?;

        Ok(instances)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::task::Task;
    use crate::user::User;

    static USERNAME: &str = "test_username";
    static NAME: &str = "test_name";

    static TASK_NAME: &str = "Exercise";

    async fn create_test_task(
        username: &str,
        name: &str,
        task_name: &str,
        connection: &Connection,
    ) -> Task {
        let user = User::insert(username, name, &connection)
            .await
            .expect("Should successfully insert. ");

        Task::insert(user.get_id(), task_name, &connection)
            .await
            .expect("Should successfully insert. ")
    }

    #[tokio::test]
    async fn test_get_instances() {
        let connection = Connection::connect_temporary_with_schema()
            .await
            .expect("Should connect");

        let task = create_test_task(USERNAME, NAME, TASK_NAME, &connection).await;

        let instance1 = Instance::insert(
            task.get_id(),
            &NaiveDateTime::from_timestamp(1, 0),
            &NaiveDateTime::from_timestamp(2, 0),
            &connection,
        )
        .await
        .expect("Should successfully insert.");

        let instance2 = Instance::insert(
            task.get_id(),
            &NaiveDateTime::from_timestamp(100, 0),
            &NaiveDateTime::from_timestamp(2123, 2),
            &connection,
        )
        .await
        .expect("Should successfully insert.");

        let instances = Instance::get_instances(task.get_id(), &connection)
            .await
            .expect("Should get all tasks.");

        println!("{:?}", instances);

        assert_eq!(instances.len(), 2);
        assert_eq!(instances[0], instance1);
        assert_eq!(instances[1], instance2);
    }
}
