import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class TopBar extends StatelessWidget implements PreferredSize {
  final Widget? customAction;
  @override
  final Widget child = Container();

  TopBar({super.key, this.customAction});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => GoRouter.of(context).pop(),
              child: const Icon(Icons.arrow_back, size: 25),
            ),
            Expanded(child: SvgPicture.asset(AppIcons.logoFull, height: 32)),
            customAction ?? const SizedBox()
          ],
        ),
      ),
    );
  }
}
