import 'dart:convert';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/map/filter_item/bool_filter_item.dart';
import 'package:beez/presentation/map/filter_item/date_filter_item.dart';
import 'package:beez/presentation/map/filter_item/distance_filter_item.dart';
import 'package:beez/presentation/map/filter_item/filter_item.dart';
import 'package:beez/presentation/map/filter_item/interest_filter_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFilters extends StatefulWidget {
  final Map<String, FilterMap> userFilters;
  final Map<String, FilterMap> defaultFilters = {
    "date": DateFilter(title: "Data", label: "Qualquer dia"),
    "free": BooleanFilter(
        title: "Gratuidade", label: "Apenas com entrada gratuita"),
    "media":
        BooleanFilter(title: "Multimídia", label: "Apenas eventos com fotos"),
    "interest": MultiSelectFilter(title: "Interesses")
  };
  final ValueChanged<Map<String, FilterMap>> onSave;
  final LatLng userLocation;

  MapFilters(
      {super.key,
      required this.userFilters,
      required this.onSave,
      required this.userLocation});

  @override
  State<MapFilters> createState() => _MapFiltersState();
}

class _MapFiltersState extends State<MapFilters> {
  Map<String, FilterMap> currentFilters = {};

  @override
  void initState() {
    super.initState();
    currentFilters.addAll(widget.defaultFilters
        .map((key, filter) => MapEntry(key, filter.copy())));
    currentFilters.addAll(
        widget.userFilters.map((key, filter) => MapEntry(key, filter.copy())));
  }

  void resetFilters() {
    setState(() {
      currentFilters["distance"] =
          (currentFilters['distance'] as RangeFilter).reset();
      currentFilters.addAll(widget.defaultFilters
          .map((key, filter) => MapEntry(key, filter.reset())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 35, vertical: 60),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Filtrar Mapa",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).pop();
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 28, color: AppColors.mediumGrey),
                  )
                ],
              ),
              currentFilters.containsKey('distance')
                  ? FilterMapItem(
                      title: currentFilters['distance']!.title,
                      child: DistanceFilterItem(
                        distanceFilter:
                            currentFilters['distance'] as RangeFilter,
                        onChanged: (newDistance) {
                          setState(() {
                            currentFilters['distance']!.currentValue =
                                newDistance;
                          });
                        },
                      ))
                  : Container(),
              FilterMapItem(
                  title: currentFilters['date']!.title,
                  child: DateFilterItem(
                      dateFilter: currentFilters['date'] as DateFilter,
                      onChangedDate: (newDate) {
                        setState(() {
                          currentFilters['date']!.currentValue = newDate;
                        });
                      },
                      onChangedAnyDate: () {
                        setState(() {
                          (currentFilters['date']! as DateFilter).anyDate =
                              !(currentFilters['date']! as DateFilter).anyDate;
                        });
                      })),
              FilterMapItem(
                  title: currentFilters['free']!.title,
                  child: BoolFilterItem(
                      boolFilter: currentFilters['free'] as BooleanFilter,
                      onChanged: () {
                        setState(() {
                          currentFilters['free']!.currentValue =
                              !currentFilters['free']!.currentValue;
                        });
                      })),
              FilterMapItem(
                  title: currentFilters['media']!.title,
                  child: BoolFilterItem(
                      boolFilter: currentFilters['media'] as BooleanFilter,
                      onChanged: () {
                        setState(() {
                          currentFilters['media']!.currentValue =
                              !currentFilters['media']!.currentValue;
                        });
                      })),
              FilterMapItem(
                  title: currentFilters['interest']!.title,
                  child: InterestFilterItem(
                      interestFilter:
                          currentFilters['interest'] as MultiSelectFilter,
                      onChanged: (values) {
                        setState(() {
                          currentFilters['interest']!.currentValue =
                              values.whereType<String>().toList();
                        });
                      })),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          widget.onSave(currentFilters);
                          GoRouter.of(context).pop();
                        },
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(AppColors.darkYellow)),
                        child: Text(
                          "Aplicar Filtros",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextButton(
                        onPressed: resetFilters,
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        child: Text(
                          "Limpar Filtros",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .merge(const TextStyle(color: AppColors.brown)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ])));
  }
}
