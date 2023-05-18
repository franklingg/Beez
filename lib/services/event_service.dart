import 'dart:async';
import 'dart:io';

import 'package:beez/models/event_model.dart';
import 'package:beez/utils/images_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventService {
  static Future<List<EventModel>> getEvents() async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('events').get();
      final events =
          query.docs.map((doc) => EventModel.fromMap(doc)).toList();
      return events;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<EventModel> getEvent(String id) async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('events').doc(id).get();
      final event = EventModel.fromMap(query);
      return event;
    } catch (e) {
      return Future.error(e);
    }
  }

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      subscribeToEvents(void Function(EventModel) action) {
    final db = FirebaseFirestore.instance;
    return db.collection('events').snapshots().listen((querySnapshot) {
      for (final docChange in querySnapshot.docChanges) {
        final changedEvent = EventModel.fromMap(docChange.doc);
        action(changedEvent);
      }
    });
  }

  static Future<EventModel> createEvent(EventModel newEvent) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = await db.collection('events').add(newEvent.toMap());
      return updateEvent(newEvent.copyWith(id: docRef.id));
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  static Future<EventModel> updateEvent(EventModel updatedEvent) async {
    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('events')
          .doc(updatedEvent.id)
          .update(updatedEvent.toMap());
      return updatedEvent;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future toggleLikeEvent(EventModel event, String info) async {
    try {
      final updatedEvent = event.copyWith();
      final db = FirebaseFirestore.instance;
      if (updatedEvent.interested.contains(info)) {
        updatedEvent.interested.remove(info);
      } else {
        updatedEvent.interested.add(info);
      }
      await db.collection('events').doc(event.id).update(updatedEvent.toMap());
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future<List<String>> uploadPhotos(List<MultiImage?> photos) async {
    final storage = FirebaseStorage.instance.ref('event/');
    final existingPhotos = photos.whereNotNull();
    final result = existingPhotos
        .where((photo) => photo.source == MultiImageSource.NETWORK)
        .map((photo) => photo.url!)
        .toList();

    final photosToUpload = existingPhotos
        .where((photo) => photo.source == MultiImageSource.UPLOAD);
    for (final photo in photosToUpload) {
      final file = File(photo.file!.path);
      final imageRef = storage.child(
          "${DateTime.now().millisecondsSinceEpoch.toString()}${extension(file.path)}");
      try {
        await imageRef.putFile(file);
        result.add(await imageRef.getDownloadURL());
      } on FirebaseException catch (_) {
        return Future.error("Erro ao subir fotos");
      }
    }
    return result;
  }
}
