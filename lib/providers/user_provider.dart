import 'package:beez/constants/app_images.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final List<UserModel> _allUsers = [];
  String? currentUserId;

  UserProvider() {
    UserService.subscribeToUsers(firestoreAction: (changedUser) {
      int userIndex = _allUsers.indexWhere((user) => user.id == changedUser.id);
      // If new user
      if (userIndex == -1) {
        _allUsers.add(changedUser);
      } else {
        _allUsers[userIndex] = changedUser;
      }
      notifyListeners();
    }, fireauthAction: (userId) {
      currentUserId = userId;
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

  UserModel? findUser(String email) {
    final userIdx = _allUsers.indexWhere((user) => user.email == email);
    return (userIdx != -1 ? _allUsers[userIdx] : null);
  }

  bool shouldShowEvents({String? userId}) {
    if (userId != null) {
      final user = getUser(userId);
      final currentUserFollowers =
          currentUserId != null ? getUser(currentUserId!).followers : [];
      return user.id == currentUserId ||
          user.showEventsAll ||
          (user.showEventsFollowers && currentUserFollowers.contains(user.id));
    }
    return false;
  }

  ImageProvider getProfilePic({String? userId, bool yellow = false}) {
    UserModel? user = userId != null ? getUser(userId) : null;
    return user != null && user.profilePic.isNotEmpty
        ? NetworkImage(user.profilePic)
        : AssetImage(
                yellow ? AppImages.placeholder : AppImages.placeholderWhite)
            as ImageProvider;
  }
}
