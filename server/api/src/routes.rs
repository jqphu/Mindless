use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::{http::RawStr, response::NamedFile, Request, State};
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
#[rocket::async_trait]
impl<'r> Responder<'r> for ResponseError {
    async fn respond_to(self, request: &'r Request<'_>) -> response::Result<'r> {
        let body = format!(
            "Error: {:#?}\n\nRequest: {:#?}\n\nBacktrace: {:#?}",
            self.0,
            request,
            self.0.backtrace()
        );

        // Print the error to the console too.
        println!("\n\n{}\n\n", body);

        Ok(Response::build()
            .status(Status::InternalServerError)
            .header(ContentType::Plain)
            .sized_body(Cursor::new(body))
            .await
            .finalize())
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
pub async fn favicon() -> Option<NamedFile> {
    NamedFile::open("static/favicon.ico").ok()
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

    // TODO: Verify the date.
    habit.mark_habit().await?;

    Ok(format!("Habit '{}' has been marked as done!", &habit.name))
}
