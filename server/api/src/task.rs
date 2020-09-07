use database::connection::Connection;
use database::user::User;
use rocket::State;
use rocket_contrib::json::Json;
use serde::{Deserialize, Serialize};

use crate::error::Result;
use database::instance::Instance;
use database::task::Task;

// Type of events that you can execute on a user.
#[derive(Deserialize, Debug)]
pub enum Request {
    // Retrieve all the tasks.
    RetrieveAll { user_id: i64 },

    // Insert all of the tasks!
    InsertAll { tasks: Vec<(Task, Vec<Instance>)> },
}

#[derive(Serialize, Debug)]
pub enum Response {
    RetrieveAll { tasks: Vec<(Task, Vec<Instance>)> },

    // All the tasks with their task id.
    InsertAll { tasks: Vec<(Task, Vec<Instance>)> },
}

// Handle all interfacing with user.
#[post("/mindless/api/task", data = "<request>")]
pub async fn task(
    connection: State<'_, Connection>,
    request: Json<Request>,
) -> Result<Json<Response>> {
    println!("Recieved request: {:#?}", request);

    let return_value = match request.into_inner() {
        Request::RetrieveAll { user_id } => retrieve_all(user_id, &connection).await?,
        Request::InsertAll { tasks } => insert_all(tasks, &connection).await?,
    };

    println!("Sending response: {:#?}", return_value);

    Ok(Json(return_value))
}

pub async fn retrieve_all(user_id: i64, connection: &Connection) -> Result<Response> {
    let user = User::retrieve(user_id, &connection).await?;
    let tasks: Vec<Task> = Task::get_tasks(&user, &connection).await?;

    let mut result = Vec::new();
    for task in tasks {
        let instance = Instance::get_instances(task.get_id(), &connection).await?;
        result.push((task, instance));
    }

    Ok(Response::RetrieveAll { tasks: result })
}

pub async fn insert_all(
    tasks: Vec<(Task, Vec<Instance>)>,
    connection: &Connection,
) -> Result<Response> {
    let mut result = Vec::new();
    println!("{:#?}", tasks);
    for data in tasks {
        // Move the task out.
        let mut task = data.0;
        task.try_insert(&connection).await?;

        let mut instances = data.1;
        for instance in instances.iter_mut() {
            instance.set_task_id(task.get_id());
        }

        result.push((
            task,
            Instance::try_insert_all(instances, &connection).await?,
        ));
    }

    Ok(Response::InsertAll { tasks: result })
}
