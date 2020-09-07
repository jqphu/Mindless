use database::error::Error as DBError;
use rocket::http::{ContentType, Status};
use rocket::response::{self, Responder, Response};
use rocket::Request;
use std::convert::From;
use std::io::Cursor;

// Change the alias to use our custom http error.
pub type Result<T> = std::result::Result<T, Error>;

/// Simple wrapping type to implement the Responder trait on.
#[derive(Debug)]
pub enum Error {
    Database(DBError),
}

/// Error responder!
impl<'r> Responder<'r, 'static> for Error {
    fn respond_to(self, request: &'r Request<'_>) -> response::Result<'static> {
        let response = match &self {
            Error::Database(error) => match &error {
                DBError::UnknownSql(_) => {
                    let body = format!("Error: {:#?}\nRequest: {:#?}", error, request,);

                    Response::build()
                        .sized_body(body.len(), Cursor::new(body))
                        .status(Status::InternalServerError)
                        .header(ContentType::Plain)
                        .ok()
                }
                _ => json!({"error": error.to_string()}).respond_to(request),
            },
        };

        println!(
            "Responding with error: {:#?}\nfrom request: {:#?}",
            &response, &request
        );

        response
    }
}

impl From<DBError> for Error {
    fn from(error: DBError) -> Self {
        Error::Database(error)
    }
}
