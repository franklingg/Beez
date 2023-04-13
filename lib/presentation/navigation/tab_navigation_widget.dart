import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/navigation/navigation_item_widget.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TabNavigation extends StatelessWidget {
  const TabNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(context).location;

    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(color: AppColors.white, boxShadow: [
        BoxShadow(
            color: AppColors.boxShadow, offset: Offset(0, -1), blurRadius: 4)
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              GoRouter.of(context).pushNamed(MapScreen.name);
            },
            child: NavigationItem(
                icon: AppIcons.map,
                text: "Mapa",
                isSelected: currentLocation == "/${MapScreen.name}"),
          ),
          GestureDetector(
              onTap: () {
                GoRouter.of(context).pushNamed(FeedScreen.name);
              },
              child: NavigationItem(
                  icon: Icons.rss_feed,
                  text: "Feed",
                  isSelected: currentLocation == "/${FeedScreen.name}")),
          GestureDetector(
              onTap: () {
                GoRouter.of(context).pushNamed(ProfileScreen.name);
              },
              child: NavigationItem(
                  icon: Icons.person_outline,
                  text: "Perfil",
                  isSelected: currentLocation == "/${ProfileScreen.name}")),
        ],
      ),
    );
  }
}
