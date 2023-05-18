import 'package:beez/models/event_model.dart';
import 'package:beez/services/event_service.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> allEvents = [];

  EventProvider() {
    EventService.subscribeToEvents((changedEvent) {
      int eventIndex =
          allEvents.indexWhere((event) => event.id == changedEvent.id);
      // If new event
      if (eventIndex == -1) {
        allEvents.add(changedEvent);
      } else {
        allEvents[eventIndex] = changedEvent;
      }
      notifyListeners();
    });
  }

  void addEvent(EventModel newEvent) {
    allEvents.add(newEvent);
    notifyListeners();
  }

  void addAll(List<EventModel> initialEvents) {
    allEvents.addAll(initialEvents);
    notifyListeners();
  }

  List<EventModel> get nextEvents {
    return allEvents
        .where((event) => event.date.toDate().isAfter(DateTime.now()))
        .toList();
  }

  EventModel getEvent(String id) {
    return allEvents.firstWhere((event) => event.id == id);
  }
}
