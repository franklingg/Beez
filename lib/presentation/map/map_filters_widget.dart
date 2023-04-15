import 'package:beez/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapFilters extends StatefulWidget {
  final List<Filter> userFilters;
  final List<Filter> defaultFilters = [
    RangeFilter(title: "Distância"),
    DateFilter(title: "Data", label: "Qualquer dia"),
    TimeFilter(title: "Horário", label: "Qualquer horário"),
    BooleanFilter(title: "Gratuidade", label: "Apenas com entrada gratuita"),
    BooleanFilter(title: "Multimídia", label: "Apenas eventos com fotos/links"),
    MultiSelectFilter(title: "Interesses")
  ];

  final ValueChanged<List<Filter>> onSave;

  MapFilters({super.key, required this.userFilters, required this.onSave});

  @override
  State<MapFilters> createState() => _MapFiltersState();
}

class _MapFiltersState extends State<MapFilters> {
  late List<Filter> currentFilters;

  @override
  void initState() {
    super.initState();
    currentFilters = widget.defaultFilters
        .map((filter) => (widget.userFilters.firstWhere(
            (userFilter) => (userFilter.title == filter.title),
            orElse: () => filter)))
        .toList();
  }

  void resetFilters() {
    setState(() {
      currentFilters = widget.defaultFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            child: const Text("Fechar")));
  }
}
