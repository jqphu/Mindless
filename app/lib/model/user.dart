import 'package:http/http.dart' as http;
import 'package:mindless/server.dart';
import 'package:mindless/model/task.dart';
import 'dart:convert';

/// Represent a User.
class User {
  final String username;
  final String name;
  int id;

  Task currentTask;

  User(this.username, this.name, this.id, this.currentTask);

  Map<String, Object> toMap() {
    var map = <String, Object>{
      'username': username,
      'name': name,
    };

    if (id != null) {
      map['id'] = id;
    }

    if (currentTask != null) {
      map['current_task_id'] = currentTask.id;
    }

    return map;
  }

  User.fromJson(Map<String, dynamic> jsonUser)
      : id = jsonUser['id'],
        username = jsonUser['username'],
        name = jsonUser['name'];

  // Override toString for logging.
  @override
  String toString() {
    return 'User(id:$id, username:$username, name:$name)';
  }

  static Future<User> login(String username) async {
    if (username == 'test') {
      return Future.value(User(username, 'justin', 1, null));
    }

    var response = await http.post(kUserEndpoint,
        body: jsonEncode({
          'Login': {
            'username': username,
          }
        }));

    // Unexpected server error.
    if (response.statusCode != 200) {
      return Future.error(response.body);
    }

    // Expected server response.
    var result = jsonDecode(response.body);

    // Server had an error.
    if (result.containsKey('error')) {
      var errorType = requestErrorFromString(result['error']);
      throw RequestException(errorType);
    }

    // Successfully, requested!
    return Future.value(User.fromJson(result['Login']['user']));
  }

  static Future<User> register(String username, String name) async {
    var response = await http.post(kUserEndpoint,
        body: jsonEncode({
          'Create': {'username': username, 'name': name}
        }));

    // Unexpected server error.
    if (response.statusCode != 200) {
      return Future.error(response.body);
    }

    // Expected server response.
    var result = jsonDecode(response.body);

    // Server had an error.
    if (result.containsKey('error')) {
      var errorType = requestErrorFromString(result['error']);
      throw RequestException(errorType);
    }

    // Successfully, requested!
    return Future.value(User.fromJson(result['Create']['user']));
  }
}
