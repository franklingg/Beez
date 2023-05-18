import 'package:beez/models/event_model.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  FilterMap<T> copy();
  FilterMap<T> reset();
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
        return currentValue.isAtSameMomentAs(event.date.toDate().getDateOnly());
      }
    }).toList();
  }

  @override
  FilterMapType get type => FilterMapType.DATE;

  @override
  DateTime get defaultValue => DateTime.now().getDateOnly();

  bool anyDate = true;

  @override
  DateFilter reset() {
    return DateFilter(title: title, label: label);
  }

  @override
  DateFilter copy() {
    return DateFilter(title: title, label: label)
      ..currentValue = currentValue
      ..anyDate = anyDate;
  }
}

class RangeFilter extends FilterMap<RangeValues> {
  final LatLng? currentPosition;
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

  @override
  RangeFilter reset() {
    return RangeFilter(
        title: title, label: label, currentPosition: currentPosition);
  }

  @override
  RangeFilter copy() {
    return RangeFilter(
        title: title, label: label, currentPosition: currentPosition)
      ..currentValue = currentValue;
  }

  RangeFilter copyNewLoc(LatLng newPosition) {
    return RangeFilter(title: title, label: label, currentPosition: newPosition)
      ..currentValue = currentValue;
  }
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

  @override
  BooleanFilter reset() {
    return BooleanFilter(title: title, label: label);
  }

  @override
  BooleanFilter copy() {
    return BooleanFilter(title: title, label: label)
      ..currentValue = currentValue;
  }
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

  @override
  MultiSelectFilter reset() {
    return MultiSelectFilter(title: title, label: label);
  }

  @override
  MultiSelectFilter copy() {
    return MultiSelectFilter(title: title, label: label)
      ..currentValue = currentValue;
  }
}
