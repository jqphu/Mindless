#![feature(proc_macro_hygiene)]

#[macro_use]
extern crate rocket;
extern crate dotenv;

use sqlx::SqlitePool;

// List of all the routes.
mod routes;

#[async_std::main]
async fn main() {
    // Read the environment variables from .env file.
    dotenv::dotenv().ok();

    rocket::ignite()
        .manage(
            SqlitePool::new(
                &std::env::var("DATABASE_URL")
                    .expect("`DATBASE_URL` environment variable must be set."),
            )
            .await
            .expect("SqlitePool must be creatable."),
        )
        .mount(
            "/",
            routes![routes::index, routes::favicon, routes::mark_habit],
        )
        .register(catchers![routes::not_found])
        .launch()
        .expect("Successful launch.");
}
