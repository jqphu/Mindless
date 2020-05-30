#![feature(proc_macro_hygiene)]

#[macro_use]
extern crate rocket;

// List of all the routes.
mod routes;

fn main() {
    rocket::ignite()
        .mount("/", routes![routes::index, routes::favicon])
        .register(catchers![routes::not_found])
        .launch()
        .expect("Successful launch.");
}
