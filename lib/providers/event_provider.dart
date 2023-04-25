import 'package:beez/models/event_model.dart';
import 'package:beez/services/event_service.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> _allEvents = [];

  EventProvider() {
    EventService.subscribeToEvents((changedEvent) {
      int eventIndex = _allEvents.indexWhere((event) => event == changedEvent);
      // If new event
      if (eventIndex == -1) {
        _allEvents.add(changedEvent);
      } else {
        _allEvents[eventIndex] = changedEvent;
      }
      notifyListeners();
    });
  }

  void addEvent(EventModel newEvent) {
    _allEvents.add(newEvent);
    notifyListeners();
  }

  void addAll(List<EventModel> initialEvents) {
    _allEvents.addAll(initialEvents);
    notifyListeners();
  }

  List<EventModel> get allEvents {
    return _allEvents;
  }

  List<EventModel> get nextEvents {
    return _allEvents
        .where((event) => event.date.toDate().isAfter(DateTime.now()))
        .toList();
  }

  EventModel getEvent(String id) {
    return _allEvents.firstWhere((event) => event.id == id);
  }
}
