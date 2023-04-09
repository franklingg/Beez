import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String name = 'login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("LOGIN", style: TextStyle(color: AppColors.black)),
        ),
        bottomNavigationBar: const TabNavigation(),
      ),
    );
  }
}
