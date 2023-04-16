import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Event {
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
  Event({
    required this.id,
    required this.creator,
    required this.date,
    required this.name,
    required this.description,
    required this.interested,
    required this.location,
    required this.address,
    required this.photos,
    required this.tags,
  });

  Event copyWith({
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
  }) {
    return Event(
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
    };
  }

  factory Event.fromMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    return Event(
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
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) => Event.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Event(id: $id, creator: $creator, date: $date, name: $name, description: $description, interested: $interested, location: $location, address: $address, photos: $photos, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.id == id &&
        other.creator == creator &&
        other.date == date &&
        other.name == name &&
        other.description == description &&
        listEquals(other.interested, interested) &&
        other.location == location &&
        other.address == address &&
        listEquals(other.photos, photos) &&
        listEquals(other.tags, tags);
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
        tags.hashCode;
  }
}
