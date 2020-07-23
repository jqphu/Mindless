use rocket::http::Status;
use rocket::local::Client;

use crate::liftoff;

/// Set of e2e tests for the api.
/// TODO: This should be an integration test. Move the binary to a library and test the library.
/// TODO: This depends on data/test.db already created with tables loaded. It also does not unload
/// tables. Longer term solution is to set tests into their own crate and set up a db using the
/// build scripts.

#[async_std::test]
async fn test_welcome_page() {
    let rocket = liftoff("sqlite:data/test.db").await;
    let client = Client::new(rocket).expect("valid rocket instance");

    let response = client.get("/mindless").dispatch().await;
    assert_eq!(response.status(), Status::Ok);
}

#[async_std::test]
async fn test_mark_habit() {
    let rocket = liftoff("sqlite:data/test.db").await;
    let client = Client::new(rocket).expect("valid rocket instance");

    // TODO: Move these to separate tests. This isn't done at the moment since we haven't set up
    // shutdown for rocket server.

    // Test adding a task.
    let response = client.get("/mindless/api/habit/mark/Task").dispatch().await;
    assert_eq!(response.status(), Status::Ok);

    // Test using a web url.
    let response = client
        .get("/mindless/api/habit/mark/Task%20test")
        .dispatch()
        .await;
    assert_eq!(response.status(), Status::Ok);
}
