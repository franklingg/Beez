import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationItem extends StatelessWidget {
  final dynamic icon;
  final String text;
  final bool isSelected;
  const NavigationItem(
      {super.key,
      required this.icon,
      required this.text,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final selectedIcon = Padding(
        padding: const EdgeInsets.all(6),
        child: icon.runtimeType == String
            ? SvgPicture.asset(
                icon,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              )
            : Icon(icon, color: AppColors.white, size: 23));
    final unselectedIcon = icon.runtimeType == String
        ? SvgPicture.asset(
            icon,
            height: 30,
            colorFilter:
                const ColorFilter.mode(AppColors.mediumGrey, BlendMode.srcIn),
          )
        : Icon(icon, color: AppColors.mediumGrey, size: 30);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: isSelected
                ? Hexagon(
                    child: selectedIcon,
                    color: AppColors.darkYellow,
                  )
                : unselectedIcon),
        Text(text,
            style: TextStyle(
                color: isSelected ? AppColors.darkYellow : AppColors.mediumGrey,
                fontWeight: FontWeight.bold))
      ],
    );
  }
}
