import 'package:beez/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:go_router/go_router.dart';

class TabNavigation extends StatelessWidget {
  const TabNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(context).location;

    return Row(
      children: [
        TextButton(onPressed: () {}, child: const Icon(AppMap.map_marked_alt)),
        TextButton(onPressed: () {}, child: const Icon(Icons.rss_feed)),
        TextButton(onPressed: () {}, child: const Icon(Icons.person_outline))
      ],
    );
  }
}
