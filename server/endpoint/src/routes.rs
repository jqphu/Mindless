use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::{http::RawStr, response::NamedFile, Request, State};
use sqlx::SqlitePool;
use std::io::Cursor;

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

        Ok(Response::build()
            .status(Status::InternalServerError)
            .header(ContentType::Plain)
            .sized_body(Cursor::new(body))
            .await
            .finalize())
    }
}

#[get("/")]
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
#[get("/favicon.ico")]
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
#[get("/api/habit/mark/<habit_name>")]
pub async fn mark_habit(
    pool: State<'_, SqlitePool>,
    habit_name: &RawStr,
) -> Result<String, ResponseError> {
    // TODO: Figure out how to more nicely go directly to a ResponseError. This wrapping is
    // currently required such that we can return anyhow errors everywhere.
    match handle_mark_habit(&pool, habit_name).await {
        Err(err) => Err(ResponseError(err)),
        Ok(val) => Ok(val),
    }
}

/// The logic to mark a habit.
pub async fn handle_mark_habit(
    pool: &State<'_, SqlitePool>,
    habit_name: &RawStr,
) -> anyhow::Result<String> {
    let _connection = pool.acquire().await?;
    Ok(format!("Looks good for habit '{}'!", habit_name))
}
