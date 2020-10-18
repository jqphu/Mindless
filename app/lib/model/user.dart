import 'package:http/http.dart' as http;
import 'package:mindless/server.dart';
import 'dart:convert';

/// Represent a User.
class User {
  final String username;
  final String name;
  final int id;

  User(this.username, this.name, this.id);

  User.fromJson(Map<String, dynamic> jsonUser)
      : id = jsonUser["id"],
        username = jsonUser["username"],
        name = jsonUser["name"];

  static Future<User> login(String username) async {
    var response = await http.post(kUserEndpoint,
        body: jsonEncode({
          "Login": {
            "username": username,
          }
        }));

    // Unexpected server error.
    if (response.statusCode != 200) {
      return Future.error(response.body);
    }

    // Expected server response.
    var result = jsonDecode(response.body);

    // Server had an error.
    if (result.containsKey("error")) {
      var errorType = requestErrorFromString(result["error"]);
      throw RequestException(errorType);
    }

    // Successfully, requested!
    return Future.value(User.fromJson(result["Login"]["user"]));
  }

  static Future<User> register(String username, String name) async {
    // Dummy delay for now.
    return Future.delayed(Duration(seconds: 3));
  }
}
