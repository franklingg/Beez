import 'dart:async';

import 'package:beez/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<List<UserModel>> getUsers() async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('users').get();
      final users = query.docs.map((doc) => UserModel.fromMap(doc)).toList();
      return users;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<Position> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      final location = await Geolocator.getCurrentPosition();
      return location;
    } catch (e) {
      return Future.error(e);
    }
  }

  static void subscribeToUsers(
      {required void Function(UserModel) firestoreAction,
      required void Function(String?) fireauthAction}) {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    db.collection('users').snapshots().listen((querySnapshot) {
      for (final docChange in querySnapshot.docChanges) {
        final changedUser = UserModel.fromMap(docChange.doc);
        firestoreAction(changedUser);
      }
    });
    auth.idTokenChanges().listen((user) async {
      if (user == null) {
        UserService.clearPersistance();
        fireauthAction(null);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('@beez/userToken', await user.getIdToken());
        await prefs.setString(
            '@beez/userLoginMethod', user.providerData.first.providerId);
        fireauthAction(prefs.getString('@beez/userId'));
      }
    });
  }

  static clearPersistance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('@beez/userToken');
    await prefs.remove('@beez/userId');
    await prefs.remove('@beez/userLoginMethod');
  }

  static Future<UserModel> performNormalLogin(
      String email, String password, UserModel? userData) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('@beez/userId', userData!.id);
      return userData;
    } on FirebaseAuthException catch (error) {
      String message = "Login Falhou.";
      switch (error.code) {
        case 'invalid-email':
          message = "O e-mail inserido é inválido.";
          break;
        case 'user-not-found':
          message = "Este usuário não existe.";
          break;
        case 'wrong-password':
          message = "A senha inserida é inválida.";
          break;
        default:
          message = "Erro de Autenticação.";
      }
      return Future.error(message);
    }
  }

  static Future<void> performLogout() {
    return FirebaseAuth.instance.signOut();
  }

  static Future sendPasswordRecovery(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      String message = "Login Falhou.";
      switch (error.code) {
        case 'invalid-email':
        case 'user-not-found':
          message = "Este usuário não existe.";
          break;
        default:
          message = "Erro de Autenticação.";
      }
      return Future.error(message);
    }
  }

  static Future toggleFollowers(UserModel user, String followerId) async {
    try {
      final updatedUser = user.copyWith();
      final db = FirebaseFirestore.instance;
      if (updatedUser.followers.contains(followerId)) {
        updatedUser.followers.remove(followerId);
      } else {
        updatedUser.followers.add(followerId);
      }
      await db.collection('users').doc(user.id).update(updatedUser.toMap());
    } catch (e) {
      return Future.error(e);
    }
  }
}
