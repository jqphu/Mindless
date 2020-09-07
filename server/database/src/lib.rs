type SqlId = i64;

#[deny(clippy::all)]
pub mod connection;
#[deny(clippy::all)]
pub mod error;

// SQLx clippy errors.
#[deny(clippy::all)]
#[allow(clippy::toplevel_ref_arg)]
pub mod user;

// SQLx clippy errors.
#[deny(clippy::all)]
pub mod task;

// SQLx clippy errors.
#[deny(clippy::all)]
pub mod instance;
