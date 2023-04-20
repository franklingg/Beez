import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const name = "profile";
  final String? id;
  const ProfileScreen({super.key, this.id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("PERFIL de id ${widget.id}",
              style: TextStyle(color: AppColors.black)),
        ),
        bottomNavigationBar: const TabNavigation(),
      ),
    );
  }
}
