#![feature(proc_macro_hygiene)]

#[macro_use]
extern crate rocket;
extern crate chrono;

extern crate serde;
extern crate serde_json;

// Database queries.
extern crate database;

// List of all the routes.
mod routes;

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
        .mount("/", routes![routes::index, routes::favicon])
        .register(catchers![routes::not_found])
}
