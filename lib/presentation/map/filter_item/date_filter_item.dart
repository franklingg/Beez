import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
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

  void openDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
        locale: const Locale('pt', 'BR'),
        context: context,
        initialDate: dateFilter.currentValue,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      onChangedDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppField(
                child: GestureDetector(
                  onTap: () {
                    if (dateFilter.anyDate) onChangedAnyDate();
                    openDatePicker(context);
                  },
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: dateFilter.anyDate
                            ? Text(
                                "XX/XX",
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                            : Text(
                                getDate(dateFilter.currentValue),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                      )),
                      const Icon(Icons.calendar_month_outlined,
                          color: AppColors.darkYellow, size: 25)
                    ],
                  ),
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
                    onChangedDate(DateTime.now());
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
