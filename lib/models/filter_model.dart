import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

abstract class Filter<T> {
  late T currentValue;
  List<String> filter(List<String> data);
  FilterType get type;
  T get defaultValue;
  // final String fieldToFilter;
  String title;
  String? label;
  Filter({required this.title, this.label}) {
    currentValue = defaultValue;
  }
}

enum FilterType { DATE, TIME, RANGE, BOOL, MULTISELECT }

class DateFilter extends Filter<DateTime> {
  DateFilter({required super.title, super.label});

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.DATE;

  @override
  DateTime get defaultValue => DateTime.now();

  bool anyDate = false;
}

class TimeFilter extends Filter<TimeOfDay> {
  TimeFilter({required super.title, super.label});

  @override
  TimeOfDay get defaultValue => const TimeOfDay(hour: 0, minute: 0);

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.TIME;

  bool anyTime = false;
}

class RangeFilter extends Filter<Tuple2<int, int>> {
  RangeFilter({required super.title, super.label});

  @override
  Tuple2<int, int> get defaultValue => const Tuple2(0, 30);

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.RANGE;

  bool isMaxDistance() => currentValue.item2 == defaultValue.item2;
}

class BooleanFilter extends Filter<bool> {
  BooleanFilter({required super.title, super.label});

  @override
  bool get defaultValue => false;

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.BOOL;
}

class MultiSelectFilter extends Filter<List<String>> {
  MultiSelectFilter({required super.title, super.label});

  @override
  List<String> get defaultValue => [];

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.MULTISELECT;
}
