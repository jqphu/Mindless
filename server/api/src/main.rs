#![feature(proc_macro_hygiene)]

#[macro_use]
extern crate rocket;
extern crate chrono;
extern crate dotenv;

extern crate serde;

use sqlx::SqlitePool;

// List of all the routes.
mod routes;

// Database queries.
mod database;

#[cfg(test)]
mod tests;

#[async_std::main]
async fn main() {
    // Read the environment variables from .env file.
    dotenv::dotenv().ok();

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
            SqlitePool::new(database_url)
                .await
                .expect("SqlitePool must be creatable."),
        )
        .mount(
            "/",
            routes![
                routes::index,
                routes::favicon,
                routes::mark_habit,
                routes::unmark_habit
            ],
        )
        .register(catchers![routes::not_found])
}
