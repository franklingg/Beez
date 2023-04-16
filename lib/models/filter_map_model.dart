import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

abstract class FilterMap<T> {
  late T currentValue;
  List<String> filter(List<String> data);
  FilterMapType get type;
  T get defaultValue;
  // final String fieldToFilter;
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
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterMapType get type => FilterMapType.DATE;

  @override
  DateTime get defaultValue => DateTime.now();

  bool anyDate = true;
}

class RangeFilter extends FilterMap<RangeValues> {
  RangeFilter({required super.title, super.label});

  @override
  RangeValues get defaultValue => const RangeValues(0, 30);

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
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
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterMapType get type => FilterMapType.BOOL;
}

class MultiSelectFilter extends FilterMap<List<String>> {
  MultiSelectFilter({required super.title, super.label});

  @override
  List<String> get defaultValue => [];

  @override
  List<String> filter(List<String> data) {
    // TODO: implement filter
    throw UnimplementedError();
  }

  @override
  FilterMapType get type => FilterMapType.MULTISELECT;
}
