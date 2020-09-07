/// Represent a User.
class User {
  static Future<User> login(String username) async {
    return Future.delayed(Duration(seconds: 3));
  }
}
