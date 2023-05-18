import 'dart:async';
import 'dart:io';

import 'package:beez/models/user_model.dart';
import 'package:beez/utils/images_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
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

  // TODO: phone changed action
  static Future<UserModel> updateUser(
      UserModel updatedUser, String? password, bool phoneChanged) async {
    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toMap());
      await FirebaseAuth.instance.currentUser!.updateEmail(updatedUser.email);
      if (password != null) {
        await FirebaseAuth.instance.currentUser!.updatePassword(password);
      }
      return updatedUser;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<String> uploadUserPhoto(MultiImage? userPhoto) async {
    final storage = FirebaseStorage.instance.ref('avatar/');
    String result = '';
    if (userPhoto != null && userPhoto.source == MultiImageSource.UPLOAD) {
      final file = File(userPhoto.file!.path);
      final imageRef = storage.child(
          "${DateTime.now().millisecondsSinceEpoch.toString()}${extension(file.path)}");
      try {
        await imageRef.putFile(file);
        result = await imageRef.getDownloadURL();
      } on FirebaseException catch (_) {
        return Future.error("Erro ao subir foto de perfil");
      }
    } else if (userPhoto != null) {
      result = userPhoto.url!;
    }
    return result;
  }
}
