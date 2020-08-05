use database;

#[test]
fn create_user() {
    let _user = database::user::User::new("MyNewUser".to_string());

    // Verify tests work!
    assert_eq!(2 + 2, 4);
}
