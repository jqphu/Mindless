import 'package:flutter/foundation.dart';
import 'user.dart';

class UserStateModel extends ChangeNotifier {
  /// User that is logged in. The user never is cleared.
  final User _user;

  /// Initialize the AppStateModel with the user.
  UserStateModel(this._user) {
    assert(_user != null);
  }

  String get username {
    return _user.username;
  }

  String get name {
    return _user.name;
  }
}
