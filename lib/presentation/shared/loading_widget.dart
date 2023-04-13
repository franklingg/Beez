import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Loading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const Loading({super.key, required this.child, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Stack(alignment: AlignmentDirectional.center, children: [
            child,
            Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.shadow),
                child: Stack(alignment: Alignment.center, children: [
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.yellow,
                    ),
                  ),
                  SvgPicture.asset(
                    AppIcons.logoSmall,
                    height: 40,
                  )
                ])),
          ])
        : child;
  }
}
