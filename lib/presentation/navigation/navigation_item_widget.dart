import 'package:beez/constants/app_colors.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
              decoration: isSelected
                  ? const ShapeDecoration(
                      color: AppColors.darkYellow,
                      shape: PolygonBorder(
                          sides: 6,
                          side: BorderSide(color: AppColors.darkYellow)))
                  : null,
              child: Padding(
                  padding: EdgeInsets.all(isSelected ? 6 : 0),
                  child: icon.runtimeType == String
                      ? SvgPicture.asset(
                          icon,
                          height: isSelected ? 20 : 30,
                          colorFilter: ColorFilter.mode(
                              isSelected
                                  ? AppColors.white
                                  : AppColors.mediumGrey,
                              BlendMode.srcIn),
                        )
                      : Icon(icon,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.mediumGrey,
                          size: isSelected ? 20 : 30))),
        ),
        Text(text,
            style: TextStyle(
                color: isSelected ? AppColors.darkYellow : AppColors.mediumGrey,
                fontWeight: FontWeight.bold))
      ],
    );
  }
}
