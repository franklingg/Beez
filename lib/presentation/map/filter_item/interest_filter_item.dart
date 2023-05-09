import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_tags.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class InterestFilterItem extends StatelessWidget {
  final MultiSelectFilter interestFilter;
  final Function(List<String>) onChanged;
  final double? itemSize;

  const InterestFilterItem(
      {super.key,
      required this.interestFilter,
      required this.onChanged,
      this.itemSize});

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
              title: Container(
                width: 310,
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text("Interesses",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .merge(const TextStyle(
                                    fontWeight: FontWeight.w600))),
                      ),
                      GestureDetector(
                          onTap: () {
                            onChanged([]);
                            ctx.pop();
                          },
                          child: const Icon(
                            Icons.layers_clear,
                            size: 24,
                          ))
                    ]),
              ),
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
                textStyle: TextStyle(fontSize: itemSize),
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
