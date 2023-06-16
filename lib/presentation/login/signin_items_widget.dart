import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SignInItems extends StatelessWidget {
  const SignInItems({super.key});

  void activateLogin(BuildContext context, SignInMethod method) {
    AuthService.performLogin(context: context, method: method).then((user) {
      GoRouter.of(context).pushNamed(MapScreen.name);
    }).onError((String errorMsg, _) {
      AppAlerts.error(alertContext: context, errorMessage: errorMsg);
    });
  }

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
                onPressed: () => activateLogin(context, SignInMethod.FACEBOOK),
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
                onPressed: () => activateLogin(context, SignInMethod.GOOGLE),
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
                onPressed: () => activateLogin(context, SignInMethod.TWITTER),
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
