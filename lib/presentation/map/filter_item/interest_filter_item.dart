import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_tags.dart';
import 'package:beez/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class InterestFilterItem extends StatelessWidget {
  final MultiSelectFilter interestFilter;
  final Function(List<String>) onChanged;

  const InterestFilterItem(
      {super.key, required this.interestFilter, required this.onChanged});

  Future openInterestsSheet(
      BuildContext context, MultiSelectFilter interestFilter) async {
    await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return MultiSelectBottomSheet(
              initialChildSize: 0.8,
              maxChildSize: 1,
              listType: MultiSelectListType.CHIP,
              separateSelectedItems: true,
              cancelText: const Text("Cancelar"),
              confirmText: const Text("Confirmar"),
              selectedColor: AppColors.yellow,
              itemsTextStyle: Theme.of(context).textTheme.labelSmall,
              selectedItemsTextStyle: Theme.of(context).textTheme.labelSmall,
              title: Text("Interesses",
                  style: Theme.of(context).textTheme.displayMedium),
              items: AppTags.items,
              initialValue: interestFilter.currentValue,
              onConfirm: onChanged);
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey, width: 2)),
          child: Row(
            children: [
              Expanded(
                  child: MultiSelectChipDisplay(
                scroll: true,
                height: 35,
                items: interestFilter.currentValue
                    .map((t) => MultiSelectItem(t, t))
                    .toList(),
              )),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.black, size: 35)
            ],
          ),
        ),
        onTap: () {
          openInterestsSheet(context, interestFilter);
        });
  }
}
