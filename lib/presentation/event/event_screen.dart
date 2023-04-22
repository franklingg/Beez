import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  static const String name = 'event';
  final String? id;
  const EventScreen({super.key, this.id});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TopBar(),
        body: Column(children: []),
        bottomNavigationBar: const TabNavigation(),
      ),
    );
  }
}
