import 'package:beez/models/event_model.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

abstract class FilterMap<T> {
  late T currentValue;
  List<EventModel> filter(List<EventModel> data);
  FilterMapType get type;
  T get defaultValue;
  String title;
  String? label;
  FilterMap({required this.title, this.label}) {
    currentValue = defaultValue;
  }
}

// ignore: constant_identifier_names
enum FilterMapType { DATE, TIME, RANGE, BOOL, MULTISELECT }

class DateFilter extends FilterMap<DateTime> {
  DateFilter({required super.title, super.label});

  @override
  List<EventModel> filter(List<EventModel> data) {
    return data.where((event) {
      if (anyDate) {
        return true;
      } else {
        return currentValue.isBefore(event.date.toDate());
      }
    }).toList();
  }

  @override
  FilterMapType get type => FilterMapType.DATE;

  @override
  DateTime get defaultValue => DateTime.now().getDateOnly();

  bool anyDate = true;
}

class RangeFilter extends FilterMap<RangeValues> {
  final Position? currentPosition;
  RangeFilter({required super.title, super.label, this.currentPosition});

  @override
  RangeValues get defaultValue => const RangeValues(0, 30);

  @override
  List<EventModel> filter(List<EventModel> data) {
    return data.where((event) {
      if (currentPosition == null) return true;
      final currentDistance = Geolocator.distanceBetween(
          event.location.latitude,
          event.location.longitude,
          currentPosition!.latitude,
          currentPosition!.longitude);
      return (currentDistance >= currentValue.start * 1000) &&
          (currentDistance <= currentValue.end * 1000);
    }).toList();
  }

  @override
  FilterMapType get type => FilterMapType.RANGE;

  bool isMaxDistance() => currentValue.end == defaultValue.end;
}

class BooleanFilter extends FilterMap<bool> {
  BooleanFilter({required super.title, super.label});

  @override
  bool get defaultValue => false;

  @override
  List<EventModel> filter(List<EventModel> data) {
    return data.where((event) {
      return !currentValue ||
          (title == "Gratuidade" ? event.isFree : event.photos.isNotEmpty);
    }).toList();
  }

  @override
  FilterMapType get type => FilterMapType.BOOL;
}

class MultiSelectFilter extends FilterMap<List<String>> {
  MultiSelectFilter({required super.title, super.label});

  @override
  List<String> get defaultValue => [];

  @override
  List<EventModel> filter(List<EventModel> data) {
    return data.where((event) {
      return currentValue.isEmpty ||
          currentValue.any((filterTag) => event.tags.contains(filterTag));
    }).toList();
  }

  @override
  FilterMapType get type => FilterMapType.MULTISELECT;
}
