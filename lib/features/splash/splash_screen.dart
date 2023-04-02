import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.yellow),
        child: Padding(
          padding: const EdgeInsets.only(left: 34, right: 56),
          child: Center(
            child: Image.asset(AppImages.fullLogo),
          ),
        ),
      ),
    );
  }
}
