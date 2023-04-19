import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EventModel {
  String id;
  String creator;
  Timestamp date;
  String name;
  String description;
  List<String> interested;
  GeoPoint location;
  String address;
  List<String> photos;
  List<String> tags;
  bool isFree;
  EventModel(
      {required this.id,
      required this.creator,
      required this.date,
      required this.name,
      required this.description,
      required this.interested,
      required this.location,
      required this.address,
      required this.photos,
      required this.tags,
      required this.isFree});

  EventModel copyWith({
    String? id,
    String? creator,
    Timestamp? date,
    String? name,
    String? description,
    List<String>? interested,
    GeoPoint? location,
    String? address,
    List<String>? photos,
    List<String>? tags,
    bool? isFree,
  }) {
    return EventModel(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      date: date ?? this.date,
      name: name ?? this.name,
      description: description ?? this.description,
      interested: interested ?? this.interested,
      location: location ?? this.location,
      address: address ?? this.address,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      isFree: isFree ?? this.isFree,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator': creator,
      'date': date,
      'name': name,
      'description': description,
      'interested': interested,
      'location': location,
      'address': address,
      'photos': photos,
      'tags': tags,
      'isFree': isFree,
    };
  }

  factory EventModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() as Map<String, dynamic>;
    return EventModel(
        id: doc.id,
        creator: map['creator'] ?? '',
        date: map['date'],
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        interested: List<String>.from(map['interested']),
        location: map['location'],
        address: map['address'] ?? '',
        photos: List<String>.from(map['photos']),
        tags: List<String>.from(map['tags']),
        isFree: map['isFree'] ?? true);
  }

  String toJson() => json.encode(toMap());

  factory EventModel.fromJson(String source) =>
      EventModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EventModel(id: $id, creator: $creator, date: $date, name: $name, description: $description, interested: $interested, location: $location, address: $address, photos: $photos, tags: $tags, isFree: $isFree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        creator.hashCode ^
        date.hashCode ^
        name.hashCode ^
        description.hashCode ^
        interested.hashCode ^
        location.hashCode ^
        address.hashCode ^
        photos.hashCode ^
        tags.hashCode ^
        isFree.hashCode;
  }
}
