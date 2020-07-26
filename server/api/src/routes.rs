use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::{http::RawStr, response::NamedFile, Request, State};
use serde::Deserialize;
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

/// Entrypoint to unmark a habit.
///
#[get("/mindless/api/habit/unmark/<habit_name_raw>")]
pub async fn unmark_habit(
    pool: State<'_, SqlitePool>,
    habit_name_raw: &RawStr,
) -> Result<String, ResponseError> {
    // TODO: Figure out how to more nicely go directly to a ResponseError. This wrapping is
    // currently required such that we can return anyhow errors everywhere.
    match handle_unmark_habit(&pool, habit_name_raw).await {
        Err(err) => Err(ResponseError(err)),
        Ok(val) => Ok(val),
    }
}

/// The logic to unmark a habit.
pub async fn handle_unmark_habit(
    pool: &State<'_, SqlitePool>,
    habit_name_raw: &RawStr,
) -> anyhow::Result<String> {
    let habit_name = habit_name_raw.url_decode()?;
    let connection = pool.acquire().await?;

    let mut habit = database::Habit {
        connection,
        name: habit_name,
    };

    habit.unmark_habit().await?;

    Ok(format!(
        "Habit '{}' has been unmarked as done!",
        &habit.name
    ))
}

/// Entrypoint to mark a habit.
///
/// TODO: Make this read in JSON taking in an optional time to mark at.
#[get("/mindless/api/habit/mark/<habit_name_raw>")]
pub async fn mark_habit(
    pool: State<'_, SqlitePool>,
    habit_name_raw: &RawStr,
) -> Result<String, ResponseError> {
    // TODO: Figure out how to more nicely go directly to a ResponseError. This wrapping is
    // currently required such that we can return anyhow errors everywhere.
    match handle_mark_habit(&pool, habit_name_raw).await {
        Err(err) => Err(ResponseError(err)),
        Ok(val) => Ok(val),
    }
}

/// The logic to mark a habit.
pub async fn handle_mark_habit(
    pool: &State<'_, SqlitePool>,
    habit_name_raw: &RawStr,
) -> anyhow::Result<String> {
    let habit_name = habit_name_raw.url_decode()?;
    let connection = pool.acquire().await?;

    let mut habit = database::Habit {
        connection,
        name: habit_name,
    };

    habit.mark_habit().await?;

    Ok(format!("Habit '{}' has been marked as done!", &habit.name))
}
