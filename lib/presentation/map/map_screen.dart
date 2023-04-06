import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/presentation/shared/tab_navigation_widget.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  static const name = "map";
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("MAPA", style: TextStyle(color: AppColors.black)),
        ),
        bottomNavigationBar: TabNavigation(),
      ),
    );
  }
}
