

import 'package:fttq/domain/models/user.dart';
import 'package:fttq/fttq.dart';

class AuthStore extends Store {
  User _user;

  setUser(User newUser) => _user = newUser;
  get user => _user;

  @override
  dispose() {}
}