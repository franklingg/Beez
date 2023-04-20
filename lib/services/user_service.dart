import 'package:beez/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}
