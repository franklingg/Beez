import 'dart:async';

import 'package:beez/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  static Future<List<EventModel>> getEvents() async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('events').get();
      final events = query.docs.map((doc) => EventModel.fromMap(doc)).toList();
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

  static Future updateEvent(EventModel updatedEvent) async {
    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('events')
          .doc(updatedEvent.id)
          .update(updatedEvent.toMap());
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
}
