#![feature(proc_macro_hygiene)]
#![feature(async_closure)]

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
extern crate chrono;

extern crate serde;
extern crate serde_json;

// Database queries.
extern crate database;

// List of common routes.
mod routes;
// User routes
mod user;
// Task routes
mod task;
// Errors
mod error;

#[tokio::main]
async fn main() {
    let database_url =
        &std::env::var("DATABASE_URL").expect("`DATBASE_URL` environment variable must be set.");

    liftoff(database_url)
        .await
        .launch()
        .await
        .expect("Successful launch.");
}

/// Start the rocket server.
///
/// Separate this from main in order to use it in tests.
pub async fn liftoff(database_url: &str) -> rocket::Rocket {
    rocket::ignite()
        .manage(
            database::connection::Connection::connect(database_url)
                .await
                .expect("Should connect to database."),
        )
        .mount(
            "/",
            routes![routes::index, routes::favicon, user::user, task::task],
        )
        .register(catchers![routes::not_found])
}
