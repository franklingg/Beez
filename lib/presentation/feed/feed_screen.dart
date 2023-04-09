import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/feed/feed_card_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  static const name = "feed";
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLoading = true;
  Position? _userLocation;
  @override
  void initState() {
    super.initState();
    UserService.getUserCurrentLocation().then((location) {
      setState(() {
        _userLocation = location;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: isLoading,
        child: Scaffold(
          appBar: TopBar(),
          body: Stack(
            children: [
              Consumer<EventProvider>(builder: (_, eventProvider, __) {
                final shownEvents = eventProvider.nextEvents;
                return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    itemCount: shownEvents.length,
                    prototypeItem: shownEvents.isNotEmpty
                        ? FeedCard(data: shownEvents.first)
                        : null,
                    itemBuilder: ((context, index) {
                      final eventData = shownEvents[index];
                      double? distanceUserEvent;
                      if (_userLocation != null) {
                        distanceUserEvent = Geolocator.distanceBetween(
                                _userLocation!.latitude,
                                _userLocation!.longitude,
                                eventData.location.latitude,
                                eventData.location.longitude) /
                            1000;
                      }
                      return FeedCard(
                        data: eventData,
                        distanceFromUser: distanceUserEvent,
                      );
                    }));
              }),
              Positioned(
                right: 5,
                bottom: 20,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                      onTap: () {
                        if (UserService.currentUser == null) {
                          AppAlerts.login(alertContext: context);
                        } else {
                          GoRouter.of(context).pushNamed(FeedScreen.name);
                        }
                      },
                      child: const Hexagon(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add_rounded,
                            size: 30, color: AppColors.black),
                      )))
                ]),
              )
            ],
          ),
          bottomNavigationBar: const TabNavigation(),
        ),
      ),
    );
  }
}
