import 'package:beez/models/user_model.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final List<UserModel> _allUsers = [];

  UserProvider() {
    UserService.subscribeToUsers((changedUser) {
      int userIndex = _allUsers.indexWhere((user) => user == changedUser);
      // If new user
      if (userIndex == -1) {
        _allUsers.add(changedUser);
      } else {
        _allUsers[userIndex] = changedUser;
      }
      notifyListeners();
    });
  }

  void addUser(UserModel newUser) {
    _allUsers.add(newUser);
    notifyListeners();
  }

  void addAll(List<UserModel> initialUsers) {
    _allUsers.addAll(initialUsers);
    notifyListeners();
  }

  List<UserModel> get allUsers {
    return _allUsers;
  }

  UserModel getUser(String id) {
    return _allUsers.firstWhere((user) => user.id == id);
  }
}
