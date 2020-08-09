use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::{response::NamedFile, Request};
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
