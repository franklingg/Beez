// ignore_for_file: constant_identifier_names

import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum OrderOption {
  NEAREST_DISTANT(description: "Menos Distante"),
  FARTHEST_DISTANT(description: "Mais Distante"),
  FURTHEST_DATE(description: "Menos Próximo"),
  CLOSEST_DATE(description: "Mais Próximo"),
  LESS_COMMON_FOLLOWERS(description: "Menos seguidores em comum interessados"),
  MORE_COMMON_FOLLOWERS(description: "Mais seguidores em comum interessados");

  const OrderOption({required this.description});

  final String description;
}

extension OrderOptionExtension on OrderOption {
  String get iconPath {
    switch (this) {
      case OrderOption.NEAREST_DISTANT:
        return AppIcons.distanceMinus;
      case OrderOption.FARTHEST_DISTANT:
        return AppIcons.distancePlus;
      case OrderOption.FURTHEST_DATE:
        return AppIcons.calendarMinus;
      case OrderOption.CLOSEST_DATE:
        return AppIcons.calendarPlus;
      case OrderOption.LESS_COMMON_FOLLOWERS:
        return AppIcons.followersMinus;
      case OrderOption.MORE_COMMON_FOLLOWERS:
        return AppIcons.followersPlus;
    }
  }
}

class OrderFeed extends StatelessWidget {
  final void Function(OrderOption) changeOrder;
  final OrderOption? selectedOption;
  final bool showFollowersOption;
  const OrderFeed(
      {super.key,
      this.selectedOption,
      required this.changeOrder,
      this.showFollowersOption = false});

  DropdownMenuItem<OrderOption> menuItemBuilder(
      BuildContext context, OrderOption option) {
    return DropdownMenuItem<OrderOption>(
        value: option,
        child: Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.grey))),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SvgPicture.asset(
              option.iconPath,
              height: 25,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  option.description,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            )
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2(
      customButton: SvgPicture.asset(
        AppIcons.order,
        height: 18,
      ),
      items: OrderOption.values
          .where((option) =>
              (option != OrderOption.LESS_COMMON_FOLLOWERS &&
                  option != OrderOption.MORE_COMMON_FOLLOWERS) ||
              showFollowersOption)
          .map((option) => menuItemBuilder(context, option))
          .toList(),
      onChanged: (orderPicked) {
        if (orderPicked != null) changeOrder(orderPicked);
      },
      value: selectedOption,
      dropdownStyleData: DropdownStyleData(
        width: 190,
        offset: const Offset(0, -15),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.zero,
        selectedMenuItemBuilder: (context, child) {
          return Container(
            decoration: const BoxDecoration(color: AppColors.yellow),
            child: child,
          );
        },
      ),
    ));
  }
}
