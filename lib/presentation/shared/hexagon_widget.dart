import 'package:beez/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';

class Hexagon extends StatelessWidget {
  final Widget child;
  final double size;
  const Hexagon({super.key, this.size = 20, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const ShapeDecoration(
            color: AppColors.yellow,
            shape: PolygonBorder(
                sides: 6, side: BorderSide(color: AppColors.yellow))),
        child: child);
  }
}
