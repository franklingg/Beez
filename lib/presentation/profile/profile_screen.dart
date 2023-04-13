import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const name = "profile";
  final int id;
  const ProfileScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("PERFIL", style: TextStyle(color: AppColors.black)),
        ),
        bottomNavigationBar: TabNavigation(),
      ),
    );
  }
}
