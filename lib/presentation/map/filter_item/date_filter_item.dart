import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class DateFilterItem extends StatelessWidget {
  final DateFilter dateFilter;
  final Function(DateTime) onChangedDate;
  final Function() onChangedAnyDate;

  const DateFilterItem(
      {super.key,
      required this.dateFilter,
      required this.onChangedDate,
      required this.onChangedAnyDate});

  String getDate(DateTime date) {
    return "${date.day}/${date.month.toString().padLeft(2, '0')}";
  }

  String getTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey, width: 2)),
                child: Row(
                  children: [
                    Expanded(
                      child: dateFilter.anyDate
                          ? Text(
                              "XX/XX",
                              style: Theme.of(context).textTheme.labelMedium,
                            )
                          : Text(
                              getDate(dateFilter.currentValue),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ),
                    const Icon(Icons.calendar_month_outlined,
                        color: AppColors.darkYellow, size: 25)
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
                child: Row(
              children: [
                GFCheckbox(
                  size: 25,
                  activeBgColor: AppColors.green,
                  inactiveBorderColor: AppColors.mediumGrey,
                  type: GFCheckboxType.circle,
                  onChanged: (_) {
                    onChangedAnyDate();
                  },
                  value: dateFilter.anyDate,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: GestureDetector(
                    onTap: onChangedAnyDate,
                    child: Text(
                      "Qualquer dia",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                )
              ],
            ))
          ],
        )
      ],
    );
  }
}
