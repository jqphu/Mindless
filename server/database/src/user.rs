/// This is a struct representing a user.
///
/// It abstracts the sql queries away.
pub struct User {
    /// The user id.
    pub id: i32,

    /// The name of this user.
    pub name: String,
}

impl User {
    // Create a new connection to the database representing a user.
    pub async fn new(name: String) -> Self {
        User { id: 0, name }
    }
}
