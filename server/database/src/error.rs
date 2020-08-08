use std::error;
use std::fmt;
// Change the alias to use our custom database error.
pub type Result<T> = std::result::Result<T, Error>;

/// The error code for constraint violated.
const SQLITE_CONSTRAINT_UNIQUE_CODE: &str = "2067";

#[derive(Debug)]
pub enum Error {
    // Field already exists in SQL database.
    AlreadyExists,

    // Some sql error occurred.
    UnknownSql(sqlx::Error),
}

impl PartialEq for Error {
    fn eq(&self, other: &Self) -> bool {
        use Error::*;
        if let (AlreadyExists, AlreadyExists) |
            // For the sake of simplicity, we treat all UnknownSql errors the same.
            (UnknownSql(_), UnknownSql(_))
                = (&self, &other) {
                    return true;
        }

        false
    }
}

impl Eq for Error {}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Error::AlreadyExists => write!(f, "Already exists."),
            Error::UnknownSql(ref e) => write!(f, "Unknown SQL error: \"{}\"", e),
        }
    }
}

impl error::Error for Error {
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        match *self {
            Error::AlreadyExists => None,
            // The cause is the underlying implementation error type. Is implicitly
            // cast to the trait object `&error::Error`. This works because the
            // underlying type already implements the `Error` trait.
            Error::UnknownSql(ref e) => Some(e),
        }
    }
}

/// Implement forwarding conversion from sqlx error.
impl From<sqlx::Error> for Error {
    fn from(err: sqlx::Error) -> Error {
        if let sqlx::error::Error::Database(e) = &err {
            if let Some(code) = e.code() {
                if SQLITE_CONSTRAINT_UNIQUE_CODE == code {
                    return Error::AlreadyExists;
                }
            }
        }

        Error::UnknownSql(err)
    }
}
