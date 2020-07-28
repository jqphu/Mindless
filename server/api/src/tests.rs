use rocket::http::ContentType;
use rocket::http::Status;
use rocket::local::asynchronous::Client;

use crate::liftoff;
use crate::routes::HabitRequest;
use crate::routes::HabitResponse;

/// Set of e2e tests for the api.
/// TODO: This should be an integration test. Move the binary to a library and test the library.
/// TODO: This depends on data/test.db already created with tables loaded. It also does not unload
/// tables. Longer term solution is to set tests into their own crate and set up a db using the
/// build scripts.

fn reset_database(database_name: &str) {
    let output = std::process::Command::new("data/reset_database.sh")
        .args(&[database_name.to_string()])
        .output()
        .expect("Should clear database");

    println!("Reset database output: {:?}", output);
}

#[tokio::test]
async fn test_welcome_page() {
    let rocket = liftoff("sqlite:data/test.db").await;
    let client = Client::new(rocket).await.expect("valid rocket instance");

    let response = client.get("/mindless").dispatch().await;
    assert_eq!(response.status(), Status::Ok);
}

/// Whether the request succeeded or failed.
async fn habit_request(client: &Client, username: &str, task: &str, mark: bool) -> bool {
    let mark_habit_request = HabitRequest::new(username.to_string(), task.to_string(), mark);
    let response = client
        .post("/mindless/api/habit")
        .header(ContentType::JSON)
        .body(serde_json::to_string(&mark_habit_request).expect("Serialization should not fail."))
        .dispatch()
        .await;
    assert_eq!(response.status(), Status::Ok);

    let raw_response_bytes = response.into_string().await.expect("Has a response body");

    let response_object = serde_json::from_str::<HabitResponse>(&raw_response_bytes)
        .expect("Correctly serialized response.");

    return response_object.succeded;
}

#[tokio::test]
async fn test_habit() {
    reset_database("data/test.db");
    let rocket = liftoff("sqlite:data/test.db").await;
    let client = Client::new(rocket).await.expect("valid rocket instance");

    test_single_user(&client).await;
    test_multiple_users(&client).await;
}

async fn test_single_user(client: &Client) {
    // TODO: Move these to separate tests. This isn't done at the moment since we haven't set up
    // shutdown for rocket server.
    let task_name = "Task";
    let username = "test_user";

    // Mark succeeds.
    assert!(habit_request(&client, username, task_name, true).await);

    //// Second mark fails.
    assert!(!habit_request(&client, username, task_name, true).await);

    //// Unmarking succeeds.
    assert!(habit_request(&client, username, task_name, false).await);

    //// Second unmark fails.
    assert!(!habit_request(&client, username, task_name, false).await);

    // Marking multiple habits.
    assert!(habit_request(&client, username, "abc", true).await);
    assert!(habit_request(&client, username, "zxc", true).await);
    assert!(habit_request(&client, username, "Test habit!", true).await);

    // Unmark multiple habits.
    assert!(habit_request(&client, username, "zxc", false).await);
    assert!(habit_request(&client, username, "Test habit!", false).await);
    assert!(habit_request(&client, username, "abc", false).await);
}

async fn test_multiple_users(client: &Client) {
    let username_a = "test_user_a";
    let username_b = "test_user_b";

    let task_a = "task_a";
    let task_b = "task_b";

    assert!(habit_request(&client, username_a, task_a, true).await);
    assert!(habit_request(&client, username_b, task_b, true).await);
    assert!(habit_request(&client, username_a, task_b, true).await);
    assert!(habit_request(&client, username_b, task_a, true).await);

    assert!(habit_request(&client, username_b, task_a, false).await);
    assert!(habit_request(&client, username_b, task_b, false).await);
    assert!(habit_request(&client, username_a, task_b, false).await);
    assert!(habit_request(&client, username_a, task_a, false).await);
}
