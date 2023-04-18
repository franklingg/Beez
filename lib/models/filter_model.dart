import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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

// ignore: constant_identifier_names
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

  bool anyDate = true;
}

class RangeFilter extends Filter<RangeValues> {
  RangeFilter({required super.title, super.label});

  @override
  RangeValues get defaultValue => const RangeValues(0, 30);

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterType get type => FilterType.RANGE;

  bool isMaxDistance() => currentValue.end == defaultValue.end;
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
