import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class BoolFilterItem extends StatelessWidget {
  final BooleanFilter boolFilter;
  final Function() onChanged;

  const BoolFilterItem(
      {super.key, required this.boolFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GFCheckbox(
        size: 30,
        activeBgColor: AppColors.green,
        inactiveBorderColor: AppColors.mediumGrey,
        type: GFCheckboxType.circle,
        onChanged: (newValue) {
          onChanged();
        },
        value: boolFilter.currentValue,
      ),
      const SizedBox(width: 8),
      Expanded(
          child: GestureDetector(
              onTap: onChanged, child: Text(boolFilter.label ?? "")))
    ]);
  }
}
