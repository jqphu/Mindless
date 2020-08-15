use database::connection::Connection;
use database::user::User;
use rocket::State;
use rocket_contrib::json::Json;
use serde::{Deserialize, Serialize};

use crate::error::Result;

// Type of events that you can execute on a user.
#[derive(Deserialize, Debug)]
pub enum Request {
    // Create a user.
    Create { username: String, name: String },

    // Delete a user.
    Delete { id: i64 },

    // Update a user.
    Update { user: User },
}

#[derive(Serialize, Debug)]
pub enum Response {
    Create { user: User },

    Delete,

    Update { user: User },
}

// Handle all interfacing with user.
#[post("/mindless/api/user", data = "<request>")]
pub async fn user(
    connection: State<'_, Connection>,
    request: Json<Request>,
) -> Result<Json<Response>> {
    match request.into_inner() {
        Request::Create { username, name } => {
            let user = User::insert(&username, &name, &connection).await?;
            Ok(Json(Response::Create { user }))
        }

        Request::Delete { id } => {
            User::retrieve(id, &connection)
                .await?
                .delete(&connection)
                .await?;

            Ok(Json(Response::Delete))
        }

        Request::Update { mut user } => {
            user.update(&connection).await?;

            Ok(Json(Response::Update { user }))
        }
    }
}
