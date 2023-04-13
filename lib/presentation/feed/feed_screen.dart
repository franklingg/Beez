import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  static const name = "feed";
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("FEED", style: TextStyle(color: AppColors.black)),
        ),
        bottomNavigationBar: TabNavigation(),
      ),
    );
  }
}
