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
}
