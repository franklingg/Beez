import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/feed/feed_card_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedScreen extends StatefulWidget {
  static const name = "feed";
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLoading = true;
  List<EventModel> _allEvents = [];
  Position? _userLocation;
  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((location) {
      setState(() {
        _userLocation = location;
      });
    }).whenComplete(() {
      getEvents().then((events) {
        setState(() {
          _allEvents = events;
          isLoading = false;
        });
      });
    });
  }

  Future<List<EventModel>> getEvents() async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('events').get();
      final events = query.docs.map((doc) => EventModel.fromMap(doc)).toList();
      return events;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Position> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      final location = await Geolocator.getCurrentPosition();
      return location;
    } catch (e) {
      return Future.error(e);
    }
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
              ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  itemCount: _allEvents.length,
                  prototypeItem: _allEvents.isNotEmpty
                      ? FeedCard(data: _allEvents.first)
                      : null,
                  itemBuilder: ((context, index) {
                    final eventData = _allEvents[index];
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
                  })),
              Positioned(
                right: 5,
                bottom: 20,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                      onTap: () {
                        if (FirebaseAuth.instance.currentUser == null) {
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
