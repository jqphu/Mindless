use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::{response::NamedFile, Request, State};
use rocket_contrib::json::Json;
use serde::{Deserialize, Serialize};
use sqlx::SqlitePool;
use std::io::Cursor;

use crate::database;

/// Simple wrapping type to implement the Responder trait on.
///
pub struct ResponseError(anyhow::Error);

/// Implement a trivial error responder for ResponseError.
///
/// This simply takes an anyhow error and prints the details within it when it responds.
/// Responds with 500 (InternalServerError) and information about the request and error.
// TODO: Remove this once we update clippy to fix this error.
// I think this is an async fn bug (https://github.com/rust-lang/rust-clippy/issues/3988).
#[allow(clippy::needless_lifetimes)]
impl<'r> Responder<'r, 'static> for ResponseError {
    fn respond_to(self, request: &'r Request<'_>) -> response::Result<'static> {
        println!("Error is: {:#?}", &self.0);

        let body = format!(
            "Error: {:#?}\n\nRequest: {:#?}\n\nBacktrace: {:#?}",
            self.0,
            request,
            self.0.backtrace()
        );

        Response::build()
            .sized_body(body.len(), Cursor::new(body))
            .status(Status::InternalServerError)
            .header(ContentType::Plain)
            .ok()
    }
}

#[get("/mindless")]
pub async fn index() -> &'static str {
    "
 **       **   ********   **           ******      *******     ****     ****   ********
/**      /**  /**/////   /**          **////**    **/////**   /**/**   **/**  /**/////
/**   *  /**  /**        /**         **    //    **     //**  /**//** ** /**  /**
/**  *** /**  /*******   /**        /**         /**      /**  /** //***  /**  /*******
/** **/**/**  /**////    /**        /**         /**      /**  /**  //*   /**  /**////
/**** //****  /**        /**        //**    **  //**     **   /**   /    /**  /**
/**/   ///**  /********  /********   //******    //*******    /**        /**  /********
//       //   ////////   ////////     //////      ///////     //         //   ////////
"
}

/// Default and only favicon.
#[get("/mindless/favicon.ico")]
pub async fn favicon() -> NamedFile {
    // TODO: Don't assume this always exists.
    NamedFile::open("static/favicon.ico")
        .await
        .expect("does not error")
}

#[catch(404)]
pub fn not_found(req: &Request) -> String {
    let not_found_404 = r#"
    .---.    .----.      .---.
   / .  |   /  ..  \    / .  |
  / /|  |  .  /  \  .  / /|  |
 / / |  |_ |  |  '  | / / |  |_
/  '-'    |'  \  /  '/  '-'    |
`----|  |-' \  `'  / `----|  |-'
     `--'    `---''       `--'
     "#;

    format!(
        r#"{}
Sorry, '{}' is not a valid path.

Debug Information:

{:#?}
        "#,
        not_found_404,
        req.uri(),
        req
    )
}

/// The JSON request object when manipulating habits.
#[derive(Serialize, Deserialize, Debug)]
pub struct HabitRequest {
    // The name of the habit we are requesting on.
    name: String,

    // Whether to mark or unmark the request.
    should_mark: bool,
}

impl HabitRequest {
    pub fn new(name: String, should_mark: bool) -> Self {
        HabitRequest { name, should_mark }
    }
}

/// The JSON reponse object.
///
/// This contains any logical errors or other useful information.
#[derive(Serialize, Deserialize, Debug)]
pub struct HabitResponse {
    // Whether the request was successful.
    pub succeded: bool,

    // Some additional metadata if needed.
    pub metadata: Option<String>,
}

impl HabitResponse {
    /// Create a habit response.
    pub fn new(succeded: bool, metadata: Option<String>) -> Self {
        HabitResponse {
            succeded,
            metadata: metadata,
        }
    }
}

// What to do on a user.
#[derive(Deserialize, Debug)]
enum UserAction {
    // Create a user.
    CREATE,

    // Delete a user.
    DELETE,
}

/// The JSON request object when manipulating user.
#[derive(Deserialize, Debug)]
pub struct UserRequests {
    username: String,

    // Action to be applied to username.
    action: UserAction,
}

// Handle all interfacing with user.
#[post("/mindless/api/user", data = "<user_request>")]
pub async fn user(
    pool: State<'_, SqlitePool>,
    user_request: Json<UserRequests>,
) -> Result<Json<bool>, ResponseError> {
    match handle_user_request(pool, user_request.into_inner()).await {
        Err(err) => Err(ResponseError(err)),
        Ok(val) => Ok(Json(val)),
    }
}

pub async fn handle_user_request(
    pool: State<'_, SqlitePool>,
    user_request: UserRequests,
) -> anyhow::Result<bool> {
    let mut user = database::User::new(pool.acquire().await?, user_request.username).await?;

    match user_request.action {
        UserAction::CREATE => {
            // Do nothing, the user is always egarly create in new.
        }
        UserAction::DELETE => {
            user.delete().await?;
        }
    }

    Ok(true)
}

#[post("/mindless/api/habit", data = "<habit_request_json>")]
pub async fn habit(
    pool: State<'_, SqlitePool>,
    habit_request_json: Json<HabitRequest>,
) -> Result<Json<HabitResponse>, ResponseError> {
    println!(
        "Habit request post received with data: {:#?}",
        habit_request_json
    );

    let habit_request = habit_request_json.into_inner();

    let result = if habit_request.should_mark {
        handle_mark_habit(pool, habit_request.name).await
    } else {
        handle_unmark_habit(pool, habit_request.name).await
    };

    match result {
        Err(err) => Err(ResponseError(err)),
        Ok(val) => Ok(Json(val)),
    }
}

/// The logic to unmark a habit.
pub async fn handle_unmark_habit(
    pool: State<'_, SqlitePool>,
    habit_name: String,
) -> anyhow::Result<HabitResponse> {
    let connection = pool.acquire().await?;

    let mut habit = database::Habit {
        connection,
        name: habit_name,
    };

    let succeeded = habit.unmark_habit().await?;

    Ok(HabitResponse::new(succeeded, None))
}

/// The logic to mark a habit.
pub async fn handle_mark_habit(
    pool: State<'_, SqlitePool>,
    habit_name: String,
) -> anyhow::Result<HabitResponse> {
    let connection = pool.acquire().await?;

    let mut habit = database::Habit {
        connection,
        name: habit_name,
    };

    let succeeded = habit.mark_habit().await?;

    Ok(HabitResponse::new(succeeded, None))
}
