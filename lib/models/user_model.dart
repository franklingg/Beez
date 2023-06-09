import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  Timestamp birthDate;
  String email;
  List<String> followers;
  List<String> interests;
  String name;
  String phone;
  String profilePic;
  bool showEventsAll;
  bool showEventsFollowers;
  bool verifiedPhone;
  UserModel(
      {required this.id,
      required this.birthDate,
      required this.email,
      required this.followers,
      required this.interests,
      required this.name,
      required this.phone,
      required this.profilePic,
      required this.showEventsAll,
      required this.showEventsFollowers,
      required this.verifiedPhone});

  UserModel copyWith(
      {String? id,
      Timestamp? birthDate,
      String? email,
      List<String>? followers,
      List<String>? following,
      List<String>? interests,
      String? name,
      String? phone,
      String? profilePic,
      bool? showEventsAll,
      bool? showEventsFollowers,
      bool? verifiedPhone}) {
    return UserModel(
        id: id ?? this.id,
        birthDate: birthDate ?? this.birthDate,
        email: email ?? this.email,
        followers: followers ?? this.followers,
        interests: interests ?? this.interests,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        profilePic: profilePic ?? this.profilePic,
        showEventsAll: showEventsAll ?? this.showEventsAll,
        showEventsFollowers: showEventsFollowers ?? this.showEventsFollowers,
        verifiedPhone: verifiedPhone ?? this.verifiedPhone);
  }

  Map<String, dynamic> toMap() {
    return {
      'birthDate': birthDate,
      'email': email,
      'followers': followers,
      'interests': interests,
      'name': name,
      'phone': phone,
      'profilePic': profilePic,
      'showEventsAll': showEventsAll,
      'showEventsFollowers': showEventsFollowers,
      'verifiedPhone': verifiedPhone
    };
  }

  factory UserModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() as Map<String, dynamic>;
    return UserModel(
        id: doc.id,
        birthDate: map['birthDate'] ?? Timestamp(0, 0),
        email: map['email'] ?? '',
        followers: List<String>.from(map['followers']),
        interests: List<String>.from(map['interests']),
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        profilePic: map['profilePic'] ?? '',
        showEventsAll: map['showEventsAll'] ?? false,
        showEventsFollowers: map['showEventsFollowers'] ?? false,
        verifiedPhone: map['verifiedPhone'] ?? false);
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  factory UserModel.initialize(
      String name, String email, String phone, DateTime birthDate) {
    return UserModel(
        id: 'not_set',
        birthDate: Timestamp.fromDate(birthDate),
        email: email,
        followers: [],
        interests: [],
        name: name,
        phone: phone,
        profilePic: '',
        showEventsAll: true,
        showEventsFollowers: true,
        verifiedPhone: false);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, birthDate: $birthDate, email: $email, followers: $followers, interests: $interests, name: $name, phone: $phone, profilePic: $profilePic, showEventsAll: $showEventsAll, showEventsFollowers: $showEventsFollowers, verifiedPhone: $verifiedPhone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        birthDate.hashCode ^
        email.hashCode ^
        followers.hashCode ^
        interests.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        profilePic.hashCode ^
        showEventsAll.hashCode ^
        showEventsFollowers.hashCode ^
        verifiedPhone.hashCode;
  }
}
