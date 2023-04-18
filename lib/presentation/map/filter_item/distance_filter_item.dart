import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_model.dart';
import 'package:flutter/material.dart';

class DistanceFilterItem extends StatelessWidget {
  final RangeFilter distanceFilter;
  final Function(RangeValues) onChanged;

  const DistanceFilterItem(
      {super.key, required this.distanceFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("${distanceFilter.currentValue.start.truncate()}km"),
        Expanded(
          child: SizedBox(
            height: 15,
            child: RangeSlider(
                values: distanceFilter.currentValue,
                activeColor: AppColors.darkYellow,
                min: 0,
                max: 30,
                onChanged: onChanged),
          ),
        ),
        Text("${distanceFilter.currentValue.end.truncate()}km")
      ],
    );
  }
}
