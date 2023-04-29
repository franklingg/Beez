import 'dart:async';

import 'package:beez/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

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

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Future<Position> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      final location = await Geolocator.getCurrentPosition();
      return location;
    } catch (e) {
      return Future.error(e);
    }
  }

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      subscribeToUsers(void Function(UserModel) action) {
    final db = FirebaseFirestore.instance;
    return db.collection('users').snapshots().listen((querySnapshot) {
      for (final docChange in querySnapshot.docChanges) {
        final changedUser = UserModel.fromMap(docChange.doc);
        action(changedUser);
      }
    });
  }

  static Future<String?> performNormalLogin(
      String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login bem sucedido!";
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
          message = "O e-mail inserido é inválido.";
          message = "A senha inserida é inválida.";
      }
      return Future.error(message);
    }
  }
}
