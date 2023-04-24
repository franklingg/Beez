
import 'package:beez/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final List<UserModel> _allUsers = [];

  UserProvider() {
    final db = FirebaseFirestore.instance;
    db.collection('users').snapshots().listen((querySnapshot) {
      for (final docChange in querySnapshot.docChanges) {
        final changedUser = UserModel.fromMap(docChange.doc);
        int userIndex = _allUsers.indexWhere((user) => user == changedUser);
        // If new user
        if (userIndex == -1) {
          _allUsers.add(changedUser);
        } else {
          _allUsers[userIndex] = changedUser;
        }
        notifyListeners();
      }
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