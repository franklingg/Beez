import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddEvent extends StatelessWidget {
  const AddEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      bottom: 20,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: () {
              // TODO: Update with new event screen
              GoRouter.of(context).pushNamed(FeedScreen.name);
            },
            child: const Hexagon(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add_rounded, size: 30, color: AppColors.black),
            )))
      ]),
    );
  }
}
