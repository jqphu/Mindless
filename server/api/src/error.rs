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
    Database(database::error::Error),
}

/// Error responder!
impl<'r> Responder<'r, 'static> for Error {
    fn respond_to(self, request: &'r Request<'_>) -> response::Result<'static> {
        println!("Error is: {:#?}", &self);

        let body = format!("Error: {:#?}\nRequest: {:#?}", self, request,);

        Response::build()
            .sized_body(body.len(), Cursor::new(body))
            .status(Status::InternalServerError)
            .header(ContentType::Plain)
            .ok()
    }
}

impl From<database::error::Error> for Error {
    fn from(error: database::error::Error) -> Self {
        Error::Database(error)
    }
}
