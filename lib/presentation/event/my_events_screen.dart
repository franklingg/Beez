import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyEventsScreen extends StatefulWidget {
  static const String name = 'my_events';
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<UserProvider>(builder: (_, userProvider, __) {
        return Scaffold(
          body: Consumer<EventProvider>(
            builder: (_, eventProvider, __) {
              return Column(children: [Text("MEUS EVENTOS")]);
            },
          ),
          bottomNavigationBar: const TabNavigation(),
        );
      }),
    );
  }
}
