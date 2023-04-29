import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInItems extends StatelessWidget {
  const SignInItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: AppColors.facebook)),
            child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  AppIcons.facebook,
                  height: 19,
                )),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: AppColors.google)),
            child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  AppIcons.google,
                  height: 16,
                )),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: AppColors.twitter)),
            child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  AppIcons.twitter,
                  height: 16,
                )),
          )
        ],
      ),
    );
  }
}
